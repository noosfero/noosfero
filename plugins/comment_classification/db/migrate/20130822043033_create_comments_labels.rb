class CreateCommentsLabels < ActiveRecord::Migration
  def self.up
    create_table :comment_classification_plugin_labels do |t|
      t.string      :name
      t.string      :color
      t.boolean     :enabled, :default => true
      t.references  :owner, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :comment_classification_plugin_labels
  end
end
