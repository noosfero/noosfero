class CreateVirtualCommunities < ActiveRecord::Migration
  def self.up
    create_table :virtual_communities do |t|
      t.column :name,       :string
      t.column :is_default, :boolean
      t.column :settings,   :text
      t.column :design_data, :text
    end
    VirtualCommunity.create(:name => 'Default Virtual Community', :is_default => true)
  end

  def self.down
    drop_table :virtual_communities
  end
end
