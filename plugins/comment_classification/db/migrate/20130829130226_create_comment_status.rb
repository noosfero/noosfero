class CreateCommentStatus < ActiveRecord::Migration
  def self.up
    create_table :comment_classification_plugin_statuses do |t|
      t.string      :name
      t.boolean     :enabled, :default => true
      t.boolean     :enable_reason, :default => true
      t.references  :owner, :polymorphic => true
      t.timestamps
    end

  end

  def self.down
    drop_table :comment_classification_plugin_statuses
  end
end
