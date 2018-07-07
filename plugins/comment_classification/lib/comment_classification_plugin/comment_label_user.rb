class CommentClassificationPlugin::CommentLabelUser < ApplicationRecord
  self.table_name = :comment_classification_plugin_comment_label_user

  belongs_to :profile, optional: true
  belongs_to :comment, optional: true
  belongs_to :label, class_name: 'CommentClassificationPlugin::Label', optional: true

  attr_accessible :profile, :comment, :label

  validates_presence_of :profile
  validates_presence_of :comment
  validates_presence_of :label
end
