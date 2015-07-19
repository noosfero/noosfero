class AddTimestampToRelation < ActiveRecord::Migration
  def change
    add_column :sub_organizations_plugin_relations, :created_at, :datetime
    add_column :sub_organizations_plugin_relations, :updated_at, :datetime
    add_column :sub_organizations_plugin_approve_paternity_relations, :created_at, :datetime
    add_column :sub_organizations_plugin_approve_paternity_relations, :updated_at, :datetime
  end
end
