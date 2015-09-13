class BscPlugin::Contract < ActiveRecord::Base

  validates_presence_of :bsc, :client_name

  has_many :sales, :class_name => 'BscPlugin::Sale'
  has_many :products, :through => :sales
  has_and_belongs_to_many :enterprises, :join_table => 'bsc_plugin_contracts_enterprises'

  belongs_to :bsc, :class_name => 'BscPlugin::Bsc'

  scope :status, -> status_list { where 'status in (?)', status_list if status_list.present? }
  scope :sorted_by, -> sorter, direction { order "#{sorter} #{direction}" }

  before_create do |contract|
    contract.created_at ||= Time.now.utc
    contract.updated_at ||= Time.now.utc
  end

  before_update do |contract|
    contract.updated_at ||= Time.now.utc
  end

  module Status
    OPENED = 0
    NEGOTIATING = 1
    EXECUTING = 2
    CLOSED = 3

    def self.types
      [OPENED, NEGOTIATING, EXECUTING, CLOSED]
    end

    def self.names
      [_('Opened'), _('Negotiating'), _('Executing'), _('Closed')]
    end
  end

  module ClientType
    STATE = 0
    FEDERAL = 1

    def self.types
      [STATE, FEDERAL]
    end

    def self.names
      [c_('State'), _('Federal')]
    end
  end

  module BusinessType
    PROJECTA = 0
    PROJECTB = 1

    def self.types
      [PROJECTA, PROJECTB]
    end

    def self.names
      [_('ProjectA'), _('ProjectB')]
    end
  end

  def enterprises_to_token_input
    enterprises.map { |enterprise| {:id => enterprise.id, :name => enterprise.name} }
  end

  def save_sales(sales)
    failed_sales = {}
    sales.each do |sale|
      sale.merge!({:contract_id => id})
      begin
        BscPlugin::Sale.create!(sale)
      rescue Exception => exception
        name = Product.find(sale[:product_id]).name
        failed_sales[exception.clean_message] ? failed_sales[exception.clean_message] << name : failed_sales[exception.clean_message] = [name]
      end
    end
    failed_sales
  end

  def total_price
    sales.inject(0) {|result, sale| sale.price*sale.quantity + result}
  end

end
