class CreateRelation < ActiveRecord::Migration[5.1]
  def self.up
    create_table :sub_organizations_plugin_relations do |t|
      t.references :parent, :polymorphic => true, index: {:name => 'index_2jxiUF7'}
      t.references :child, :polymorphic => true, index: {:name => 'index_mbni2uY'}
    end
  end

  def self.down
    drop_table :sub_organizations_plugin_relations
  end
end
