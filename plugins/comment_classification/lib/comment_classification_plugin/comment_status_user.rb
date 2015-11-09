class CommentClassificationPlugin::CommentStatusUser < ActiveRecord::Base
  self.table_name = :comment_classification_plugin_comment_status_user

  belongs_to :profile
  belongs_to :comment
  belongs_to :status, :class_name => 'CommentClassificationPlugin::Status'

  attr_accessible :name, :enabled, :profile, :comment, :status_id, :reason

  validates_presence_of :profile
  validates_presence_of :comment
  validates_presence_of :status
end
