class AddSecretToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :secret, :boolean, :default => false
  end
end
