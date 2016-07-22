class Product < ApplicationRecord
end
class Profile < ApplicationRecord
  has_many :products
end
class Environment < ApplicationRecord
  has_many :profiles
  has_many :products, through: :profiles

  extend ActsAsHavingSettings::ClassMethods
  acts_as_having_settings field: :settings
  settings_items :enabled_plugins, type: Array
end

class EnableProductsPluginOnEnvironments < ActiveRecord::Migration

  def up
    environments  = Environment.all
    products_used = environments.any?{ |e| e.products.count > 0 }
    return unless products_used

    Bundler.clean_system 'script/noosfero-plugins enable products'
    environments.each do |e|
      products = e.products.where('profiles.visible = true')
      next unless products.count > 0
      e.enabled_plugins << 'ProductsPlugin'
      e.save!
    end
  end

  def down
    say "this migration can't be reverted"
  end

end
