class CreateCommentStatusUser < ActiveRecord::Migration
  def self.up
    create_table :comment_classification_plugin_comment_status_user do |t|
      t.references  :profile
      t.references  :comment
      t.references  :status
      t.text        :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :comment_classification_plugin_comment_status_user
  end
end
