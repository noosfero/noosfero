require_dependency 'comment'

class Comment

  has_one :comment_classification_plugin_comment_label_user, :class_name => 'CommentClassificationPlugin::CommentLabelUser'
  has_one :label, :through => :comment_classification_plugin_comment_label_user, :foreign_key => 'label_id'

  has_many :comment_classification_plugin_comment_status_users, :class_name => 'CommentClassificationPlugin::CommentStatusUser'
  has_many :statuses, :through => :comment_classification_plugin_comment_status_users, :foreign_key => 'status_id'

end
