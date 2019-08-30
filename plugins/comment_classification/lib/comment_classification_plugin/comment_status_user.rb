class CommentClassificationPlugin::CommentStatusUser < ApplicationRecord
  self.table_name = :comment_classification_plugin_comment_status_user

  belongs_to :profile, optional: true
  belongs_to :comment, optional: true
  belongs_to :status, class_name: "CommentClassificationPlugin::Status", optional: true

  attr_accessible :name, :enabled, :profile, :comment, :status_id, :reason

  validates_presence_of :profile
  validates_presence_of :comment
  validates_presence_of :status
end
