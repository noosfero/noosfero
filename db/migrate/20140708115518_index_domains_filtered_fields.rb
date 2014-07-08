class IndexDomainsFilteredFields < ActiveRecord::Migration

  def self.up
    add_index :domains, [:name]
    add_index :domains, [:is_default]
    add_index :domains, [:owner_id, :owner_type]
    add_index :domains, [:owner_id, :owner_type, :is_default]
  end

end
