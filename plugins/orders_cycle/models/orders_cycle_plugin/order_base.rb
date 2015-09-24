# This module is needed to pretend a multiple inheritance for Sale and Purchase
module OrdersCyclePlugin::OrderBase

  extend ActiveSupport::Concern
  included do

    attr_accessible :cycle

    has_many :cycle_sales, class_name: 'OrdersCyclePlugin::CycleOrder', foreign_key: :sale_id, dependent: :destroy
    has_one  :cycle_sale,  class_name: 'OrdersCyclePlugin::CycleOrder', foreign_key: :sale_id
    has_many :cycle_purchases, class_name: 'OrdersCyclePlugin::CycleOrder', foreign_key: :purchase_id, dependent: :destroy
    has_one  :cycle_purchase,  class_name: 'OrdersCyclePlugin::CycleOrder', foreign_key: :purchase_id
    def all_cycles
      self.cycle_sales.includes(:cycle).map(&:cycle) + self.cycle_purchases.includes(:cycle).map(&:cycle)
    end

    # TODO: test if the has_one defined on Sale/Purchase works and these are not needed
    def cycle
      self.cycles.first
    end
    def cycle= cycle
      self.cycles = [cycle]
    end

    scope :for_cycle, -> (cycle) {
      where('orders_cycle_plugin_cycles.id = ?', cycle.id).
      joins(:cycles)
    }

    has_many :items, class_name: 'OrdersCyclePlugin::Item', foreign_key: :order_id, dependent: :destroy, order: 'name ASC'

    has_many :offered_products, through: :items, source: :offered_product, uniq: true
    has_many :distributed_products, through: :offered_products, source: :from_products, uniq: true
    has_many :supplier_products, through: :distributed_products, source: :from_products, uniq: true

    has_many :suppliers, through: :supplier_products, uniq: true

    extend CodeNumbering::ClassMethods
    code_numbering :code, scope: (proc do
      if self.cycle then self.cycle.send(self.orders_name) else self.profile.orders end
    end)

    def code
      I18n.t('orders_cycle_plugin.lib.ext.orders_plugin.order.cyclecode_ordercode') % {
        cyclecode: self.cycle.code, ordercode: self['code']
      }
    end

    def delivery_methods
      self.cycle.delivery_methods
    end

    def repeat_cycle= cycle
      self.items.each{ |i| i.repeat_cycle = cycle }
    end

    def available_products
      self.cycle.products
    end

    protected
  end

end
