class AddHighlightedToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :highlighted, :boolean
  end

  def self.down
    remove_column :products, :highlighted
  end
end
