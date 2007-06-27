class CreateVirtualCommunities < ActiveRecord::Migration
  def self.up
    create_table :virtual_communities do |t|
      t.column :name, :string
      t.column :domain, :string
      t.column :features, :text
    end
  end

  def self.down
    drop_table :virtual_communities
  end
end
