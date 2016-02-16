class OrdersPlugin::Order < ActiveRecord::Base

  # if abstract_class is true then it will trigger https://github.com/rails/rails/issues/20871
  #self.abstract_class = true

  Statuses = ::OrdersPlugin::Item::Statuses
  DbStatuses = ::OrdersPlugin::Item::DbStatuses
  UserStatuses = ::OrdersPlugin::Item::UserStatuses
  StatusText = ::OrdersPlugin::Item::StatusText

  # oh, we need a payments plugin!
  PaymentMethods = {
    money: proc{ _'Money' },
    check: proc{ _'shopping_cart|Check' },
    credit_card: proc{ _'Credit card' },
    bank_transfer: proc{ _'Bank transfer' },
    boleto: proc{ _'Boleto' },
  }

  # remember to translate on changes
  ActorData = [
    :name, :email, :contact_phone,
  ]
  DeliveryData = [
    :name, :description,
    :address_line1, :address_line2, :reference,
    :district, :city, :state,
    :postal_code, :zip_code,
  ]
  PaymentData = [
    :method, :change,
  ]

  # copy, for easiness. can't be declared to here to avoid cyclic reference
  StatusDataMap = ::OrdersPlugin::Item::StatusDataMap
  StatusAccessMap = ::OrdersPlugin::Item::StatusAccessMap

  StatusesByActor = {
    consumer: StatusAccessMap.map{ |s, a| s if a == :consumer }.compact,
    supplier: StatusAccessMap.map{ |s, a| s if a == :supplier }.compact,
  }

  attr_accessible :status, :consumer, :profile,
    :supplier_delivery_id, :consumer_delivery_id, :supplier_delivery_data, :consumer_delivery_data

  belongs_to :profile
  # may be override by subclasses
  belongs_to :supplier, foreign_key: :profile_id, class_name: 'Profile'
  belongs_to :consumer, class_name: 'Profile'

  belongs_to :session, primary_key: :session_id, foreign_key: :session_id, class_name: 'Session'

  has_many :items, -> { order 'name ASC' }, class_name: 'OrdersPlugin::Item', foreign_key: :order_id, dependent: :destroy
  has_many :products, through: :items

  belongs_to :supplier_delivery, class_name: 'DeliveryPlugin::Method'
  belongs_to :consumer_delivery, class_name: 'DeliveryPlugin::Method'

  scope :alphabetical, -> { joins(:consumer).reorder 'profiles.name ASC' }
  scope :latest, -> { reorder 'code ASC' }
  scope :default_order, -> { reorder 'code DESC' }

  scope :of_session, -> session_id { where session_id: session_id }
  scope :of_user, -> session_id, consumer_id=nil do
    orders = OrdersPlugin::Order.arel_table
    cond = orders[:session_id].eq(session_id)
    cond = cond.or orders[:consumer_id].eq(consumer_id) if consumer_id
    where cond
  end

  scope :latest, order: 'created_at DESC'

  scope :draft,     -> { where status: 'draft' }
  scope :planned,   -> { where status: 'planned' }
  scope :cancelled, -> { where status: 'cancelled' }
  scope :not_cancelled, -> { where "status <> 'cancelled'" }
  scope :ordered,   -> { where 'ordered_at IS NOT NULL' }
  scope :confirmed, -> { where 'ordered_at IS NOT NULL' }
  scope :accepted,  -> { where 'accepted_at IS NOT NULL' }
  scope :separated, -> { where 'separated_at IS NOT NULL' }
  scope :delivered, -> { where 'delivered_at IS NOT NULL' }
  scope :received,  -> { where 'received_at IS NOT NULL' }

  scope :for_profile, -> (profile) { where profile_id: profile.id }
  scope :for_profile_id, -> (profile_id) { where profile_id: profile_id }
  scope :for_supplier, -> (profile) { where profile_id: profile.id }
  scope :for_supplier_id, -> (profile_id) { where profile_id: profile_id }
  scope :for_consumer, -> (consumer) { where consumer_id: (consumer.id rescue nil) }
  scope :for_consumer_id, -> (consumer_id) { where consumer_id: consumer_id }

  scope :months, -> { select('DISTINCT(EXTRACT(months FROM orders_plugin_orders.created_at)) as month').order('month DESC') }
  scope :years, -> { select('DISTINCT(EXTRACT(YEAR FROM orders_plugin_orders.created_at)) as year').order('year DESC') }

  scope :by_month, -> (month) {
    where 'EXTRACT(month FROM orders_plugin_orders.created_at) <= :month AND EXTRACT(month FROM orders_plugin_orders.created_at) >= :month', month: month
  }
  scope :by_year, -> (year) {
    where 'EXTRACT(year FROM orders_plugin_orders.created_at) <= :year AND EXTRACT(year FROM orders_plugin_orders.created_at) >= :year', year: year
  }
  scope :by_range, -> (start_time, end_time) {
    where 'orders_plugin_orders.created_at >= :start AND orders_plugin_orders.created_at <= :end', start: start_time, end: end_time
  }

  scope :with_status, -> (status) { where status: status }
  scope :with_code, -> (code) { where code: code }

  validates_presence_of :profile
  # consumer is optional, as orders can be made by unlogged users
  validates_inclusion_of :status, in: DbStatuses

  before_validation :check_status
  before_validation :change_status
  after_save :send_notifications

  extend CodeNumbering::ClassMethods
  code_numbering :code, scope: -> { self.profile.orders }

  serialize :data

  extend SerializedSyncedData::ClassMethods
  sync_serialized_field :profile do |profile|
    {name: profile.name, email: profile.contact_email, contact_phone: profile.contact_phone} if profile
  end
  sync_serialized_field :consumer do |consumer|
    {name: consumer.name, email: consumer.contact_email, contact_phone: consumer.contact_phone} if consumer
  end
  sync_serialized_field :supplier_delivery
  sync_serialized_field :consumer_delivery do |consumer_delivery_data|
    if self.consumer
      h = {}; Profile::LOCATION_FIELDS.each do |field|
        h[field.to_sym] = self.consumer.send(field)
      end
      h
    end
  end
  serialize :payment_data, Hash

  # Aliases needed for terms use
  alias_method :supplier, :profile
  alias_method :supplier_data, :profile_data

  def self.search_scope scope, params
    scope = scope.with_status params[:status] if params[:status].present?
    scope = scope.for_consumer_id params[:consumer_id] if params[:consumer_id].present?
    scope = scope.for_profile_id params[:supplier_id] if params[:supplier_id].present?
    scope = scope.with_code params[:code] if params[:code].present?
    scope = scope.by_range params[:start_time], params[:end_time] if params[:start_time].present?
    scope = scope.where supplier_delivery_id: params[:delivery_method_id] if params[:delivery_method_id].present?
    scope = scope.default_order
    scope
  end

  def self.products_of orders
    # offered products in case of orders inside cycles
    Product.join(:items).includes(:suppliers).where(orders_plugin_items: {order_id: orders.map(&:id)})
  end

  # for cycle we have situation like this
  #         / Items
  #        /       \ OfferedProduct (column product_id)
  # Order /         \ SourceProduct from DistributedProduct (quantity=1, always)
  #                  \ SourceProduct from Product* (multiple for each if is an aggregate product)
  # for order outside cycle we have
  #         / Items
  #        /       \ SourceProduct from DistributedProduct (quantity=1, always)
  # Order /         \ SourceProduct from Product* (multiple for each if is an aggregate product)
  #
  # *suppliers usually don't distribute using cycles, so they only have Product
  #
  def self.supplier_products_by_suppliers orders
    products_by_supplier = {}
    items = self.parent::Item.where(order_id: orders.map(&:id)).includes(sources_supplier_products: [:supplier, :from_product])
    items.each do |item|
      if item.sources_supplier_products.present?
        item.sources_supplier_products.each do |source_sp|
          sp = source_sp.from_product
          supplier = source_sp.supplier

          products_by_supplier[supplier] ||= Set.new
          products_by_supplier[supplier] << sp
          sp.quantity_ordered ||= 0
          sp.quantity_ordered += item.status_quantity * source_sp.quantity
        end
      else
        # the case where cycles and offered products are not involved, so item is linked directly to a Product
        sp = item.product
        supplier = item.order.profile.self_supplier

        products_by_supplier[supplier] ||= Set.new
        products_by_supplier[supplier] << sp
        sp.quantity_ordered ||= 0
        sp.quantity_ordered += item.status_quantity
      end
    end

    products_by_supplier
  end

  # define on subclasses
  def orders_name
    raise 'undefined'
  end

  # override on subclasses
  def delivery_methods
    self.profile.delivery_methods
  end

  # override on subclasses
  def available_products
    self.profile.products
  end

  def actor_data actor_name
    data = {}; self.send("#{actor_name}_data").each do |k, v|
      data[k] = v if OrdersPlugin::Order::ActorData.include? k and v.present?
    end
    data = {} if data.size == 1 and data[:name].present?
    data
  end

  def actor_delivery_data actor_name
    data = {}; self.send("#{actor_name}_delivery_data").each do |k, v|
      data[k] = v if OrdersPlugin::Order::DeliveryData.include? k and v.present?
    end
    data
  end

  def delivery_data actor_name=nil
    return actor_delivery_data actor_name if actor_name

    supplier_data = actor_delivery_data :supplier
    case self.supplier_delivery_data[:delivery_type]
    when 'delivery'
      consumer_data = actor_delivery_data :consumer
      data = consumer_data.dup
      data[:name] = supplier_data[:name]
      data[:description] = supplier_data[:description]
    when 'pickup'
      data = supplier_data.dup
    end
    data
  end

  # All products from the order profile?
  # FIXME reimplement to be generic for consumer/supplier
  def self_supplier?
    return @self_supplier if @self_supplier

    self.items.each do |item|
      return @self_supplier = false unless (item.product.supplier.self? rescue true)
    end
    @self_supplier = true
  end

  def draft?
    self.status == 'draft'
  end
  alias_method :open?, :draft?
  def planned?
    self.status == 'planned'
  end
  def cancelled?
    self.status == 'cancelled'
  end
  def ordered?
    self.ordered_at.present?
  end
  def pre_order?
    not self.ordered?
  end
  alias_method :confirmed?, :ordered?

  def status_on? status
    UserStatuses.index(self.current_status) >= UserStatuses.index(status) rescue false
  end

  def current_status
    return @current_status if @current_status #cache
    return @current_status = 'open' if self.open?
    @current_status = self['status']
  end
  def status_message
    I18n.t StatusText[current_status]
  end

  def next_status actor_name
    # allow supplier to confirm and receive orders if admin is true
    actor_statuses = if actor_name == :supplier then Statuses else StatusesByActor[actor_name] end
    # if no status was found go to the first (-1 to 0)
    current_index = Statuses.index(self.status) || -1
    next_status = Statuses[current_index + 1]
    next_status if actor_statuses.index next_status rescue false
  end

  def step actor_name
    new_status = self.next_status actor_name
    self.status = new_status if new_status
  end
  def step! actor_name
    # don't crash on errors as some suppliers may have been deleted and this order may not be valid anymore
    self.save if self.step actor_name
  end

  def situation
    current_index = UserStatuses.index self.current_status || 0
    statuses = []
    UserStatuses.each_with_index do |status, i|
      statuses << status if Statuses.include? status
      break if i >= current_index
    end
    statuses << Statuses.first if statuses.empty?
    statuses
  end

  def may_view? user
    @may_view ||= self.profile.admins.include?(user) or ((self.consumer == user)) and self.profile.members.include? user
  end

  # cache is done independent of user as model cache is per request
  def may_edit? user, admin_action = false
    @may_edit ||= (admin_action and user.in? self.profile.admins) or (self.open? and self.consumer == user and user.in? self.profile.members) rescue false
  end

  def verify_actor? profile, actor_name
    (actor_name == :supplier and self.profile == profile) or (actor_name == :consumer and self.consumer == profile)
  end

  # ShoppingCart format
  def products_list
    hash = {}; self.items.map do |item|
      hash[item.product_id] = {quantity: item.quantity_consumer_ordered, name: item.name, price: item.price}
    end
    hash
  end
  def products_list= hash
    self.items = hash.map do |id, data|
      data[:quantity_consumer_ordered] = data.delete(:quantity)
      i = OrdersPlugin::Item.new data
      i.product_id = id
      i.order = self
      i
    end
  end

  def items_summary
    self.items.map{ |item| "#{item.name} (#{item.quantity_consumer_ordered_localized})" }.join ', '
  end

  extend CurrencyHelper::ClassMethods
  instance_exec &OrdersPlugin::Item::DefineTotals

  # total_price considering last state
  def total_price actor_name = :consumer, admin = false
    # for admins, we want the next_status while we concluded the finish status change
    if admin
      price = :status_price
    else
      data = StatusDataMap[self.status] || StatusDataMap[Statuses.first]
      price = "price_#{data}".to_sym
    end

    items ||= (self.ordered_items rescue nil) || self.items
    items.collect(&price).inject(0){ |sum, p| sum + p.to_f }
  end
  has_currency :total_price

  def total actor_name = :consumer, admin = false
    t = self.total_price actor_name, admin
    t += self.supplier_delivery.cost t if self.supplier_delivery.present?
    t
  end
  has_currency :total

  def fill_items from_status, to_status, save = false
    # check for status advance
    return if (Statuses.index(to_status) <= Statuses.index(from_status) rescue true)

    from_data = StatusDataMap[from_status]
    to_data = StatusDataMap[to_status]
    return unless from_data.present? and to_data.present?

    self.items.each do |item|
      # already filled?
      next if (quantity = item.send "quantity_#{to_data}").present?
      item.send "quantity_#{to_data}=", item.send("quantity_#{from_data}")
      item.send "price_#{to_data}=", item.send("price_#{from_data}")
      item.save if save
    end
  end

  def enable_product_diff
    self.items.each{ |i| i.product_diff = true }
  end

  protected

  def check_status
    self.status ||= 'draft'
    # backwards compatibility
    self.status = 'ordered' if self.status == 'confirmed'
  end

  def change_status
    return if self.status_was == self.status

    self.fill_items self.status_was, self.status, true
    self.items.update_all status: self.status
    self.building_next_status = false

    # fill dates on status advance
    if self.status_on? 'ordered'
      Statuses.each do |status|
        self.send "#{self.status}_at=", Time.now if self.status_was != status and self.status == status
      end
    else
      # status rewind for draft, planned, forgotten, cancelled, etc
      Statuses.each do |status|
        self.send "#{status}_at=", nil
      end
    end
  end

  def send_notifications
    # shopping_cart has its notifications
    return if source == 'shopping_cart_plugin'
    # ignore when status is being rewinded
    return if (Statuses.index(self.status) <= Statuses.index(self.status_was) rescue false)

    if self.status == 'ordered' and self.status_was != 'ordered'
      OrdersPlugin::Mailer.order_confirmation(self).deliver
    elsif self.status == 'cancelled' and self.status_was != 'cancelled'
      OrdersPlugin::Mailer.order_cancellation(self).deliver
    end
  end

end
