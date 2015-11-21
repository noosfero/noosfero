class OrdersCyclePlugin::Cycle < ActiveRecord::Base

  attr_accessible :profile, :status, :name, :description, :opening_message

  attr_accessible :start, :finish, :delivery_start, :delivery_finish
  attr_accessible :start_date, :start_time, :finish_date, :finish_time, :delivery_start_date, :delivery_start_time, :delivery_finish_date, :delivery_finish_time,

  Statuses = %w[edition orders purchases receipts separation delivery closing]
  DbStatuses = %w[new] + Statuses
  UserStatuses = Statuses

  # which status the sales are on each cycle status
  SaleStatusMap = {
    'edition' => nil,
    'orders' => :ordered,
    'purchases' => :accepted,
    'receipts' => :accepted,
    'separation' => :accepted,
    'delivery' => :separated,
    'closing' => :delivered,
  }
  # which status the purchases are on each cycle status
  PurchaseStatusMap = {
    'edition' => nil,
    'orders' => nil,
    'purchases' => :draft,
    'receipts' => :ordered,
    'separation' => :received,
    'delivery' => :received,
    'closing' => :received,
  }

  belongs_to :profile

  has_many :delivery_options, -> {
    where "delivery_plugin_options.owner_type = 'OrdersCyclePlugin::Cycle'"
  }, class_name: 'DeliveryPlugin::Option', dependent: :destroy, as: :owner
  has_many :delivery_methods, through: :delivery_options, source: :delivery_method

  has_many :cycle_orders, -> { order 'id ASC' }, class_name: 'OrdersCyclePlugin::CycleOrder', foreign_key: :cycle_id, dependent: :destroy

  # cannot use :order because of months/years named_scope
  has_many :sales, through: :cycle_orders, source: :sale
  has_many :purchases, through: :cycle_orders, source: :purchase

  has_many :cycle_products, foreign_key: :cycle_id, class_name: 'OrdersCyclePlugin::CycleProduct', dependent: :destroy
  has_many :products, -> {
    includes(:from_2x_products, :from_products, {profile: :domains})
  }, through: :cycle_products, class_name: 'OrdersCyclePlugin::OfferedProduct', source: :product

  has_many :consumers, -> { distinct.reorder 'name ASC' }, through: :sales, source: :consumer
  has_many :suppliers, -> { group 'suppliers_plugin_suppliers.id' }, through: :products
  has_many :orders_suppliers, -> { reorder 'name ASC' }, through: :sales, source: :profile

  has_many :from_products, -> { distinct.reorder 'name ASC' }, through: :products
  has_many :supplier_products, -> { distinct.reorder 'name ASC' }, through: :products
  has_many :product_categories, -> { distinct.reorder 'name ASC' }, through: :products

  has_many :orders_confirmed, -> { reorder('id ASC').where 'orders_plugin_orders.ordered_at IS NOT NULL' },
    through: :cycle_orders, source: :sale

  has_many :items_selled, through: :sales, source: :items
  has_many :items_purchased, through: :purchases, source: :items
  # DEPRECATED
  has_many :items, through: :orders_confirmed

  has_many :ordered_suppliers, through: :orders_confirmed, source: :suppliers

  has_many :ordered_offered_products, -> { distinct.includes :suppliers }, through: :orders_confirmed, source: :offered_products
  has_many :ordered_distributed_products, -> { distinct.includes :suppliers }, through: :orders_confirmed, source: :distributed_products
  has_many :ordered_supplier_products, -> { distinct.includes :suppliers }, through: :orders_confirmed, source: :supplier_products

  has_many :volunteers_periods, class_name: 'VolunteersPlugin::Period', as: :owner
  has_many :volunteers, through: :volunteers_periods, source: :profile
  attr_accessible :volunteers_periods_attributes
  accepts_nested_attributes_for :volunteers_periods, allow_destroy: true

  scope :has_volunteers_periods, -> { distinct.joins :volunteers_periods }

  # status scopes
  scope :on_edition, -> { where status: 'edition' }
  scope :on_orders, -> { where status: 'orders' }
  scope :on_purchases, -> { where status: 'purchases' }
  scope :on_separation, -> { where status: 'separation' }
  scope :on_delivery, -> { where status: 'delivery' }
  scope :on_closing, -> { where status: 'closing' }

  scope :defuncts, -> { where "status = 'new' AND created_at < ?", 2.days.ago }
  scope :not_new, -> { where "status <> 'new'" }
  scope :on_orders, -> {
    where "status = 'orders' AND ( (start <= :now AND finish IS NULL) OR (start <= :now AND finish >= :now) )", now: DateTime.now
  }
  scope :not_on_orders, -> {
    where "NOT (status = 'orders' AND ( (start <= :now AND finish IS NULL) OR (start <= :now AND finish >= :now) ) )", now: DateTime.now
  }
  scope :opened, -> { where "status <> 'new' AND status <> 'closing'" }
  scope :closing, -> { where "status = 'closing'" }
  scope :by_status, -> (status) { where status: status }

  scope :months, -> { order('month DESC').select 'DISTINCT(EXTRACT(months FROM start)) as month' }
  scope :years, -> { order('year DESC').select 'DISTINCT(EXTRACT(YEAR FROM start)) as year' }

  scope :by_month, -> (month) {
    where 'EXTRACT(month FROM start) <= :month AND EXTRACT(month FROM finish) >= :month', month: month
  }
  scope :by_year, -> (year) {
    where 'EXTRACT(year FROM start) <= :year AND EXTRACT(year FROM finish) >= :year', year: year
  }
  scope :by_range, -> (range) {
    where 'start BETWEEN :start AND :finish OR finish BETWEEN :start AND :finish', start: range.first, finish: range.last
  }

  validates_presence_of :profile
  validates_presence_of :name, if: :not_new?
  validates_presence_of :start, if: :not_new?
  # FIXME: The user frequenqly forget about this, and this will crash the app in some places, so don't enable this
  #validates_presence_of :delivery_options, unless: :new_or_edition?
  validates_inclusion_of :status, in: DbStatuses, if: :not_new?
  validates_numericality_of :margin_percentage, allow_nil: true, if: :not_new?
  validate :validate_orders_dates, if: :not_new?
  validate :validate_delivery_dates, if: :not_new?

  before_save :step_new
  before_validation :update_orders_status
  before_save :add_products_on_edition_state
  after_create :delay_purge_profile_defuncts

  extend CodeNumbering::ClassMethods
  code_numbering :code, scope: Proc.new { self.profile.orders_cycles }

  extend OrdersPlugin::DateRangeAttr::ClassMethods
  date_range_attr :start, :finish
  date_range_attr :delivery_start, :delivery_finish

  extend SplitDatetime::SplitMethods
  split_datetime :start
  split_datetime :finish
  split_datetime :delivery_start
  split_datetime :delivery_finish

  serialize :data, Hash

  def name_with_code
    I18n.t('orders_cycle_plugin.models.cycle.code_name') % {
      code: code, name: name
    }
  end
  def total_price_consumer_ordered
    self.items.sum :price_consumer_ordered
  end

  def status
    self['status'] = 'closing' if self['status'] == 'closed'
    self['status']
  end

  def step
    self.status = DbStatuses[DbStatuses.index(self.status)+1]
  end
  def step_back
    self.status = DbStatuses[DbStatuses.index(self.status)-1]
  end

  def passed_by? status
    DbStatuses.index(self.status) > DbStatuses.index(status) rescue false
  end

  def new?
    self.status == 'new'
  end
  def not_new?
    self.status != 'new'
  end
  def open?
    !self.closing?
  end
  def closing?
    self.status == 'closing'
  end
  def edition?
    self.status == 'edition'
  end
  def new_or_edition?
    self.status == 'new' or self.status == 'edition'
  end
  def after_orders?
    now = DateTime.now
    status == 'orders' && self.finish < now
  end
  def before_orders?
    now = DateTime.now
    status == 'orders' && self.start >= now
  end
  def orders?
    now = DateTime.now
    status == 'orders' && ( (self.start <= now && self.finish.nil?) || (self.start <= now && self.finish >= now) )
  end
  def delivery?
    now = DateTime.now
    status == 'delivery' && ( (self.delivery_start <= now && self.delivery_finish.nil?) || (self.delivery_start <= now && self.delivery_finish >= now) )
  end

  def may_order? consumer
    self.orders? and consumer.present? and consumer.in? profile.members
  end

  def consumer_previous_orders consumer
    self.profile.orders_cycles_sales.where(consumer_id: consumer.id).
      where('orders_cycle_plugin_cycle_orders.cycle_id <> ?', self.id)
  end

  def products_for_order
    self.products.unarchived.alphabetically.with_price
  end

  def supplier_products_by_suppliers orders = self.sales.ordered
    OrdersCyclePlugin::Order.supplier_products_by_suppliers orders
  end

  def generate_purchases sales = self.sales.ordered
    return self.purchases if self.purchases.present?

    sales.each do |sale|
      sale.add_purchases_items_without_delay
    end

    self.purchases true
  end
  def regenerate_purchases sales = self.sales.ordered
    self.purchases.destroy_all
    self.generate_purchases sales
  end

  def add_products
    return if self.products.count > 0
    ActiveRecord::Base.transaction do
      self.profile.products.supplied.unarchived.available.find_each batch_size: 20 do |product|
        self.add_product product
      end
    end
  end

  def add_product product
    OrdersCyclePlugin::OfferedProduct.create_from product, self
  end

  def add_products_job
    @add_products_job ||= Delayed::Job.find_by_id self.data[:add_products_job_id]
  end

  protected

  def add_products_on_edition_state
    return unless self.status_was == 'new'
    job = self.delay.add_products
    self.data[:add_products_job_id] = job.id
  end

  def step_new
    return if self.new_record?
    self.step if self.new?
  end

  def update_sales_status from, to
    sales = self.sales.where(status: from.to_s)
    sales.each do |sale|
      sale.update status: to.to_s
    end
  end

  def update_purchases_status from, to
    purchases = self.purchases.where(status: from.to_s)
    purchases.each do |purchase|
      purchase.update status: to.to_s
    end
  end

  def update_orders_status
    return if self.new? or self.status_was == "new"
    return if self.status_was == self.status

    # Don't rewind confirmed sales
    unless self.status_was == 'orders' and self.status == 'edition'
      sale_status_was = SaleStatusMap[self.status_was]
      new_sale_status = SaleStatusMap[self.status]
      self.delay.update_sales_status sale_status_was, new_sale_status unless sale_status_was == new_sale_status
    end

    # Don't rewind confirmed purchases
    unless self.status_was == 'receipts' and self.status == 'purchases'
      purchase_status_was = PurchaseStatusMap[self.status_was]
      new_purchase_status = PurchaseStatusMap[self.status]
      self.delay.update_purchases_status purchase_status_was, new_purchase_status unless purchase_status_was == new_purchase_status
    end
  end

  def validate_orders_dates
    return if self.new? or self.finish.nil?
    errors.add :base, (I18n.t('orders_cycle_plugin.models.cycle.invalid_orders_period')) unless self.start < self.finish
  end

  def validate_delivery_dates
    return if self.new? or delivery_start.nil? or delivery_finish.nil?
    errors.add :base, I18n.t('orders_cycle_plugin.models.cycle.invalid_delivery_peri') unless delivery_start < delivery_finish
    errors.add :base, I18n.t('orders_cycle_plugin.models.cycle.delivery_period_befor') unless finish <= delivery_start
  end

  def purge_profile_defuncts
    self.class.where(profile_id: self.profile_id).defuncts.destroy_all
  end

  def delay_purge_profile_defuncts
    self.delay.purge_profile_defuncts
  end

end
