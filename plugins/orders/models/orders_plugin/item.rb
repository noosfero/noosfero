class OrdersPlugin::Item < ApplicationRecord

  attr_accessible :order, :sale, :purchase,
    :product, :product_id,
    :price, :name

  # flag used by items to compare them with products
  attr_accessor :product_diff

  Statuses = %w[ordered accepted separated delivered received]
  DbStatuses = %w[draft planned cancelled] + Statuses
  UserStatuses = %w[open forgotten planned cancelled] + Statuses
  StatusText = {}; UserStatuses.map do |status|
    StatusText[status] = "orders_plugin.models.order.statuses.#{status}"
  end

  # should be Order, but can't reference it here so it would create a cyclic reference
  StatusAccessMap = {
    'ordered' => :consumer,
    'accepted' => :supplier,
    'separated' => :supplier,
    'delivered' => :supplier,
    'received' => :consumer,
  }
  StatusDataMap = {}; StatusAccessMap.each do |status, access|
    StatusDataMap[status] = "#{access}_#{status}"
  end
  StatusDataMap.each do |status, data|
    quantity = "quantity_#{data}".to_sym
    price = "price_#{data}".to_sym

    attr_accessible quantity
    attr_accessible price
  end

  serialize :data

  belongs_to :order, class_name: '::OrdersPlugin::Order', foreign_key: :order_id, touch: true
  belongs_to :sale, class_name: '::OrdersPlugin::Sale', foreign_key: :order_id, touch: true
  belongs_to :purchase, class_name: '::OrdersPlugin::Purchase', foreign_key: :order_id, touch: true

  belongs_to :product
  has_one :supplier, through: :product

  has_one :profile, through: :order
  has_one :consumer, through: :order

  # FIXME: don't work because of load order
  #if defined? SuppliersPlugin
    has_many :from_products, through: :product
    has_one :from_product, through: :product
    has_many :to_products, through: :product
    has_one :to_product, through: :product
    has_many :sources_supplier_products, through: :product
    has_one :sources_supplier_product, through: :product
    has_many :supplier_products, through: :product
    has_one :supplier_product, through: :product
    has_many :suppliers, through: :product
    has_one :supplier, through: :product
  #end

  scope :ordered, -> { joins(:order).where 'orders_plugin_orders.status = ?', 'ordered' }
  scope :for_product, -> (product) { where product_id: product.id }

  default_scope -> { includes :product }

  validate :has_order
  validates_presence_of :product
  validates_inclusion_of :status, in: DbStatuses

  before_validation :set_defaults
  before_save :save_calculated_prices
  before_save :step_status
  before_create :sync_fields

  # utility for other classes
  DefineTotals = proc do
    StatusDataMap.each do |status, data|
      quantity = "quantity_#{data}".to_sym
      price = "price_#{data}".to_sym

      self.send :define_method, "total_#{quantity}" do |items=nil|
        items ||= (self.ordered_items rescue nil) || self.items
        items.collect(&quantity).inject(0){ |sum, q| sum + q.to_f }
      end
      self.send :define_method, "total_#{price}" do |items=nil|
        items ||= (self.ordered_items rescue nil) || self.items
        items.collect(&price).inject(0){ |sum, p| sum + p.to_f }
      end

      has_number_with_locale "total_#{quantity}"
      has_currency "total_#{price}"
    end
  end

  extend CurrencyHelper::ClassMethods
  has_currency :price
  StatusDataMap.each do |status, data|
    quantity = "quantity_#{data}"
    price = "price_#{data}"

    has_number_with_locale quantity
    has_currency price

    validates_numericality_of quantity, allow_nil: true
    validates_numericality_of price, allow_nil: true
  end

  # Attributes cached from product
  def name
    self[:name] || (self.product.name rescue nil)
  end
  def price
    self[:price] || (self.product.price_with_discount || 0 rescue nil)
  end
  def price_without_margins
    self.product.price_without_margins rescue self.price
  end
  def unit
    self.product.unit
  end
  def unit_name
    self.unit.singular if self.unit
  end
  def supplier
    self.product.supplier rescue self.order.profile.self_supplier
  end
  def supplier_name
    if self.product.supplier
      self.product.supplier.abbreviation_or_name
    else
      self.order.profile.short_name
    end
  end

  def calculated_status
    status = self.order.status
    index = Statuses.index status
    next_status = Statuses[index+1] if index
    next_quantity = "quantity_#{StatusDataMap[next_status]}" if next_status
    if next_status and self.send next_quantity then next_status else status end
  end
  def on_next_status?
    self.order.status != self.calculated_status
  end

  # product used for comparizon when repeating an order
  # override on subclasses
  def repeat_product
    self.product
  end

  def next_status_quantity_field actor_name
    status = StatusDataMap[self.order.next_status actor_name] || 'consumer_ordered'
    "quantity_#{status}"
  end
  def next_status_quantity actor_name
    self.send self.next_status_quantity_field(actor_name)
  end
  def next_status_quantity_set actor_name, value
    self.send "#{self.next_status_quantity_field actor_name}=", value
  end

  def status_quantity_field
    @status_quantity_field ||= begin
      status = StatusDataMap[self.status] || 'consumer_ordered'
      "quantity_#{status}"
    end
  end
  def status_price_field
    @status_price_field ||= begin
      status = StatusDataMap[self.status] || 'consumer_ordered'
      "price_#{status}"
    end
  end

  def status_quantity
    self.send self.status_quantity_field
  end
  def status_quantity= value
    self.send "#{self.status_quantity_field}=", value
  end

  def status_price
    self.send self.status_price_field
  end
  def status_price= value
    self.send "#{self.status_price_field}=", value
  end

  StatusDataMap.each do |status, data|
    quantity = "quantity_#{data}".to_sym
    price = "price_#{data}".to_sym

    define_method "calculated_#{price}" do
      self.price * self.send(quantity) rescue nil
    end

    define_method price do
      self[price] || self.send("calculated_#{price}")
    end
  end

  def quantity_price_data actor_name
    data = {flags: {}}
    statuses = ::OrdersPlugin::Order::Statuses
    statuses_data = data[:statuses] = {}

    current = statuses.index(self.status) || 0
    next_status = self.order.next_status actor_name
    next_index = statuses.index(next_status) || current + 1
    goto_next = actor_name == StatusAccessMap[next_status]

    new_price = nil
    # compare with product
    if self.product_diff
      if self.repeat_product and self.repeat_product.available
        if self.price != self.repeat_product.price
          new_price = self.repeat_product.price
          data[:new_price] = self.repeat_product.price_as_currency_number
        end
      else
        data[:flags][:unavailable] = true
      end
    end

    # Fetch data
    statuses.each.with_index do |status, i|
      data_field = StatusDataMap[status]
      access = StatusAccessMap[status]

      status_data = statuses_data[status] = {
        flags: {},
        field: data_field,
        access: access,
      }

      quantity = self.send "quantity_#{data_field}"
      if quantity.present?
        # quantity is used on <input type=number> so it should not be localized
        status_data[:quantity] = quantity
        status_data[:flags][:removed] = true if status_data[:quantity].zero?
        status_data[:price] = self.send "price_#{data_field}_as_currency_number"
        status_data[:new_price] = quantity * new_price if new_price
        status_data[:flags][:filled] = true
      else
        status_data[:flags][:empty] = true
      end

      if i == current
        status_data[:flags][:current] = true
      elsif i == next_index and goto_next
        status_data[:flags][:admin] = true
      end

      break if (if goto_next then i == next_index else i < next_index end)
    end

    # Set flags according to past/future data
    # Present flags are used as classes
    statuses_data.each.with_index do |(status, status_data), i|
      prev_status_data = statuses_data[statuses[i-1]] unless i.zero?

      if prev_status_data
        if status_data[:quantity] == prev_status_data[:quantity]
          status_data[:flags][:not_modified] = true
        elsif status_data[:flags][:empty]
          # fill with previous status data
          status_data[:quantity] = prev_status_data[:quantity]
          status_data[:price] = prev_status_data[:price]
          status_data[:flags][:filled] = status_data[:flags].delete :empty
          status_data[:flags][:not_modified] = true
        end
      end
    end

    # reverse_each is necessary to set overwritten with intermediate not_modified
    statuses_data.reverse_each.with_index do |(status, status_data), i|
      prev_status_data = statuses_data[statuses[-i-1]]
      if status_data[:not_modified] or
          (prev_status_data and prev_status_data[:flags][:filled] and status_data[:quantity] != prev_status_data[:quantity])
        status_data[:flags][:overwritten] = true
      end
    end

    # Set access
    statuses_data.each.with_index do |(status, status_data), i|
      #consumer_may_edit = actor_name == :consumer and status == 'ordered' and self.order.open?
      if StatusAccessMap[status] == actor_name
        status_data[:flags][:editable] = true
      end
      # only allow last status
      #status_data[:flags][:editable] = true if status_data[:access] == actor_name and (status_data[:flags][:admin] or self.order.open?)
    end

    data
  end

  def calculate_prices price
    self.price = price
    self.save_calculated_prices
  end

  # used by db/migrate/20150627232432_add_status_to_orders_plugin_item.rb
  def fill_status
    status = self.calculated_status
    return if self.status == status
    self.update_column :status, status
    self.order.update_column :building_next_status, true if self.order.status != status and not self.order.building_next_status
  end

  protected

  def save_calculated_prices
    StatusDataMap.each do |status, data|
      price = "price_#{data}".to_sym
      self.send "#{price}=", self.send("calculated_#{price}")
    end
  end

  def set_defaults
    self.status ||= Statuses.first
  end

  def step_status
    status = self.calculated_status
    return if self.status == status
    self.status = status
    self.order.update_column :building_next_status, true if self.order.status != status and not self.order.building_next_status
  end

  def has_order
    self.order or self.sale or self.purchase
  end

  def sync_fields
    self.name = self.product.name
    self.price = self.product.price
  end

end
