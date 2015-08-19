class MoveFieldsIncludedOnProfilesTableToSettings < ActiveRecord::Migration
  def self.up
    Profile.find_each do |profile|
      settings = profile.shopping_cart_settings
      settings.enabled = profile.shopping_cart
      settings.delivery = profile.shopping_cart_delivery
      settings.delivery_price = profile.shopping_cart_delivery_price
      settings.save!
    end

    remove_column :profiles, :shopping_cart
    remove_column :profiles, :shopping_cart_delivery
    remove_column :profiles, :shopping_cart_delivery_price
  end

  def self.down
    say "This migration can not be reverted!"
  end
end
