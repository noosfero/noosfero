class CreateRelation < ActiveRecord::Migration
  def self.up
    create_table :sub_organizations_plugin_relations do |t|
      t.references :parent, :polymorphic => true
      t.references :child, :polymorphic => true
    end
  end

  def self.down
    drop_table :sub_organizations_plugin_relations
  end
end
