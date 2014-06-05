class CreateCommentLabelUser < ActiveRecord::Migration
  def self.up
    create_table :comment_classification_plugin_comment_label_user do |t|
      t.references  :profile
      t.references  :comment
      t.references  :label

      t.timestamps
    end

  end

  def self.down
    drop_table :comment_classification_plugin_comment_label_user
  end
end
