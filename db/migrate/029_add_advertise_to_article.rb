class AddAdvertiseToArticle < ActiveRecord::Migration
  def self.up 
    # show in recent content?
    add_column :articles,  :advertise, :boolean, :default => true
  end

  def self.down
    remove_column :articles, :advertise
  end
end
