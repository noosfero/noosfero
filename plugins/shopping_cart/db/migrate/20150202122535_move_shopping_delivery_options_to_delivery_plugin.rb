class MoveShoppingDeliveryOptionsToDeliveryPlugin < ActiveRecord::Migration
  def up
    Enterprise.find_each batch_size: 20 do |enterprise|
      settings = enterprise.shopping_cart_settings
      next if settings.delivery_options.blank?

      free_over_price = settings.free_delivery_price
      settings.delivery_options.each do |name, price|
        enterprise.delivery_methods.create! name: name, fixed_cost: price.to_f, delivery_type: 'deliver', free_over_price: free_over_price
      end

      settings.free_delivery_price = nil
      settings.delivery_options = nil
      enterprise.save!
    end
  end

  def down
    say "this migration can't be reverted"
  end
end
