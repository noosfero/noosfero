class CreateVirtualCommunities < ActiveRecord::Migration
  def self.up
    create_table :virtual_communities do |t|
      t.column :name, :string
      t.column :is_default, :boolean
    end
    ConfigurableSetting.create_table
  end

  def self.down
    ConfigurableSetting.drop_table
    drop_table :virtual_communities
  end
end
