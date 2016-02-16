class CommentClassificationPlugin::CommentLabelUser < ActiveRecord::Base
  self.table_name = :comment_classification_plugin_comment_label_user

  belongs_to :profile
  belongs_to :comment
  belongs_to :label, :class_name => 'CommentClassificationPlugin::Label'

  attr_accessible :profile, :comment, :label

  validates_presence_of :profile
  validates_presence_of :comment
  validates_presence_of :label
end
