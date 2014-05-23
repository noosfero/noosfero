require_dependency 'mark_comment_as_read_plugin/ext/comment'

class MarkCommentAsReadPlugin < Noosfero::Plugin

  def self.plugin_name
    "MarkCommentAsReadPlugin"
  end

  def self.plugin_description
    _("Provide a button to mark a comment as read.")
  end

  def js_files
    'mark_comment_as_read.js'
  end

  def stylesheet?
    true
  end

  def comment_actions(comment)
    proc do
      [{:link => link_to_function(_('Mark as not read'), 'toggle_comment_read(this, \'%s\', false);' % url_for(:controller => 'mark_comment_as_read_plugin_profile', :profile => profile.identifier, :action => 'mark_as_not_read', :id => comment.id), :class => 'comment-footer comment-footer-link comment-footer-hide comment-action-extra', :style => 'display: none', :id => "comment-action-mark-as-not-read-#{comment.id}")},
      {:link => link_to_function(_('Mark as read'), 'toggle_comment_read(this, \'%s\', true);' % url_for(:controller => 'mark_comment_as_read_plugin_profile', :profile => profile.identifier, :action => 'mark_as_read', :id => comment.id), :class => 'comment-footer comment-footer-link comment-footer-hide comment-action-extra', :style => 'display: none', :id => "comment-action-mark-as-read-#{comment.id}")}] if user
    end
  end

  def check_comment_actions(comment)
    proc do
      if user
        comment.marked_as_read?(user) ? "#comment-action-mark-as-not-read-#{comment.id}" : "#comment-action-mark-as-read-#{comment.id}"
      end
    end
  end

  def article_extra_contents(article)
    proc do
      if user
        ids = article.comments.marked_as_read(user).collect { |comment| comment.id}
        "<script type=\"text/javascript\">mark_comments_as_read(#{ids.to_json});</script>" if !ids.empty?
      end
    end
  end

end
