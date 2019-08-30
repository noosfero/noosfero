class OrdersCyclePlugin::CycleOrder < ApplicationRecord
  belongs_to :cycle, class_name: "OrdersCyclePlugin::Cycle", optional: true
  belongs_to :sale, class_name: "OrdersCyclePlugin::Sale", foreign_key: :sale_id, dependent: :destroy, optional: true
  belongs_to :purchase, class_name: "OrdersCyclePlugin::Purchase", foreign_key: :purchase_id, dependent: :destroy, optional: true

  validates_presence_of :cycle
  validate :sale_or_purchase

  protected

    def sale_or_purchase
      errors.add :base, "Specify a sale of purchase" unless self.sale_id || self.purchase_id
    end
end
