module CommentHelper
  include DatesHelper

  def article_title(article, args = {})
    title = article.title
    title = content_tag('h1', h(title), :class => 'title')
    if article.belongs_to_blog?
      unless args[:no_link]
        title = content_tag('h1', link_to(article.title, article.url), :class => 'title')
      end
      comments = ''
      unless args[:no_comments] || !article.accept_comments
        comments = (" - %s") % link_to_comments(article)
      end
      title << content_tag('span',
        content_tag('span', show_date(article.published_at), :class => 'date') +
        content_tag('span', [_(", by %s") % link_to(article.author_name, article.author_url)], :class => 'author') +
        content_tag('span', comments, :class => 'comments'),
        :class => 'publishing-info'
      )
    end
    title
  end

  def comment_extra_contents(comment)
    @plugins.dispatch(:comment_extra_contents, comment).collect do |extra_content|
      extra_content.kind_of?(Proc) ? self.instance_exec(&extra_content) : extra_content
    end.join('\n')
  end

  def comment_actions(comment)
    url = url_for(:profile => profile.identifier, :controller => :comment, :action => :check_actions, :id => comment.id)
    links = links_for_comment_actions(comment)
    links_submenu = []
    links_action_bar = []
    links.each_with_index do |link, i|
      if link[:action_bar].blank?
        links_submenu << link[:link]
      else
        links_action_bar << link[:link]
      end
    end
    render :partial => 'comment/comment_actions', :locals => {:links_submenu => links_submenu, :links_action_bar => links_action_bar, :url => url, :comment => comment}
  end

  private

  def links_for_comment_actions(comment)
    actions = [
                link_for_reply(comment),
                link_for_report_abuse(comment),
                link_for_spam(comment),
                link_for_edit(comment),
                link_for_remove(comment)
              ]

    @plugins.dispatch(:comment_actions, comment).collect do |action|
      actions << (action.kind_of?(Proc) ? self.instance_exec(&action) : action)
    end
    actions.flatten.compact
  end

  def link_for_report_abuse(comment)
    if comment.author
      report_abuse_link = report_abuse(comment.author, :comment_link, comment)
      {:link => report_abuse_link} if report_abuse_link
    end
  end

  def link_for_spam(comment)
    if comment.can_be_marked_as_spam_by?(user)
      if comment.spam?
        title = font_awesome('bug', _('Mark as not Spam'))
        { :link => link_to( title, '#!',
                            :class => 'comment-action remove-children',
                            :data => { :url => url_for(:profile => profile.identifier,
                                                       :mark_comment_as_ham => comment.id)})}
      else
        title = font_awesome('bug', _('Mark as Spam'))
        { :link => link_to( title, '#!',
                            :class => 'comment-action remove-children',
                            :data => { :message => _('Are you sure you want ' +
                                                     'to mark this comment as SPAM?'),
                            :url => url_for(:profile => profile.identifier,
                                            :controller => 'comment',
                                            :action => :mark_as_spam,
                                            :id => comment.id)})}
      end
    end
  end

  def link_for_edit(comment)
    if comment.can_be_updated_by?(user)
      title = font_awesome(:edit, _('Edit'))
      {:link => expirable_content_reference(comment, :edit, title,
                                            url_for(:profile => profile.identifier,
                                                    :controller => :comment,
                                                    :action => :edit,
                                                    :id => comment.id),
                                                    :modal => true,
                                                    :class => 'comment-edit')}
    end
  end

  def link_for_remove(comment)
    if comment.can_be_destroyed_by?(user)
      title = font_awesome('trash-o', _('Remove'))
      { :link => link_to(title, '#!', :class => 'comment-action remove-children',
                         :data => { :message => _('Are you sure you want ' +
                                                  'to remove this comment ' +
                                                  'and all its replies?'),
                         :url => url_for(:profile => profile.identifier,
                                         :controller => 'comment',
                                         :action => :destroy,
                                         :id => comment.id)})}
    end
  end

  def link_for_reply(comment)
    if comment.article.accept_comments && !comment.spam
      title = font_awesome(:reply, 'Reply')
      { :link => link_to( title, '#!', :class => 'reply-comment-link',
                          :data => { 'comment-id' => comment.id },
                          :title => _('Reply'))}
    end
  end

end
