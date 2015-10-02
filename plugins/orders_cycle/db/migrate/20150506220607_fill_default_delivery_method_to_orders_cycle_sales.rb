class FillDefaultDeliveryMethodToOrdersCycleSales < ActiveRecord::Migration
  def up
    OrdersCyclePlugin::Sale.find_each batch_size: 50 do |sale|
      next unless sale.cycle.present?
      sale.update_column :supplier_delivery_id, sale.supplier_delivery_id
    end
  end

  def down
    say "this migration can't be reverted"
  end
end
