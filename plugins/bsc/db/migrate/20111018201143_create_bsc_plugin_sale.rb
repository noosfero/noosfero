class CreateBscPluginSale < ActiveRecord::Migration
  def self.up
    create_table :bsc_plugin_sales do |t|
      t.references  :product,   :null => false
      t.references  :contract,  :null => false
      t.integer     :quantity,  :null => false
      t.decimal     :price
      t.timestamps
    end
  end

  def self.down
    drop_table :bsc_plugin_sales
  end
end
