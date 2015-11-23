class MoveItemsToOrdersCyclePluginItem < ActiveRecord::Migration
  def up
    OrdersCyclePlugin::Cycle.find_each batch_size: 5 do |cycle|
      cycle.items_selled.update_all type: 'OrdersCyclePlugin::Item'
      cycle.items_purchased.update_all type: 'OrdersCyclePlugin::Item'
    end
  end

  def down
    say "this migration can't be reverted"
  end
end
