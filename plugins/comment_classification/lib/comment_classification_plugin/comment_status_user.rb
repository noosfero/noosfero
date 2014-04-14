class CommentClassificationPlugin::CommentStatusUser < Noosfero::Plugin::ActiveRecord
  set_table_name :comment_classification_plugin_comment_status_user

  belongs_to :profile
  belongs_to :comment
  belongs_to :status, :class_name => 'CommentClassificationPlugin::Status'

  validates_presence_of :profile
  validates_presence_of :comment
  validates_presence_of :status
end
