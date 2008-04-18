class AddAdvertiseToArticle < ActiveRecord::Migration
  def self.up 
    # show in recent content?
    add_column :articles, :advertise, :boolean, :default => true

    # add this column by hand while acts_as_versioned dont have a method for update versioned table
    add_column :article_versions, :advertise, :boolean, :default => true
  end

  def self.down
    remove_column :articles, :advertise

    # remove this column by hand while acts_as_versioned dont have a method for downdate versioned table
    remove_column :article_versions, :advertise
  end
end
