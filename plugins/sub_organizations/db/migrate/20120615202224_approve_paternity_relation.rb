class ApprovePaternityRelation < ActiveRecord::Migration[5.1]
  def self.up
    create_table :sub_organizations_plugin_approve_paternity_relations do |t|
      t.references :task, index: {:name => 'index_bBvYTF8d'}
      t.references :parent, :polymorphic => true, index: {:name => 'index_NCUfh71'}
      t.references :child, :polymorphic => true, index: {:name => 'index_mLciDq6'}
    end
  end

  def self.down
    drop_table :sub_organizations_plugin_approve_paternity_relations
  end
end
