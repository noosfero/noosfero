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
      read_comment = comment.marked_as_read?(user).present?
      [{:link => link_to_function(font_awesome('times', _('Mark as not read')),
                                 'toggle_comment_read(this, \'%s\', false);' %
                                 url_for(:controller => 'mark_comment_as_read_plugin_profile',
                                         :profile => profile.identifier,
                                         :action => 'mark_as_not_read',
                                         :id => comment.id),
                                 :class => 'mark-comment-link mark-comment-not-read',
                                 :data => { :show => read_comment },
                                 :id => "comment-action-mark-as-not-read-#{comment.id}")},
      {:link => link_to_function(font_awesome(:check, _('Mark as read')),
                                 'toggle_comment_read(this, \'%s\', true);' %
                                 url_for(:controller => 'mark_comment_as_read_plugin_profile',
                                         :profile => profile.identifier,
                                         :action => 'mark_as_read',
                                         :id => comment.id),
                                 :class => 'mark-comment-link mark-comment-read',
                                 :data => { :show => !read_comment },
                                 :id => "comment-action-mark-as-read-#{comment.id}")},
      {:link => link_to(font_awesome('check-square'), '#!', :class => 'read-comment-icon'),
                        :title => _('Comment read'), :action_bar => true }] if user
    end
  end

  def check_comment_actions(comment)
    proc do
      if user
        comment.marked_as_read?(user) ? "#comment-action-mark-as-not-read-#{comment.id}" : "#comment-action-mark-as-read-#{comment.id}"
      end
    end
  end
end
