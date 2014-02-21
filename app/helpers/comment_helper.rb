module CommentHelper

  def article_title(article, args = {})
    title = article.title
    title = content_tag('h1', h(title), :class => 'title')
    if article.belongs_to_blog?
      unless args[:no_link]
        title = content_tag('h1', link_to(article.name, article.url), :class => 'title')
      end
      comments = ''
      unless args[:no_comments] || !article.accept_comments
        comments = (" - %s") % link_to_comments(article)
      end
      title << content_tag('span',
        content_tag('span', show_date(article.published_at), :class => 'date') +
        content_tag('span', [_(", by %s") % link_to(article.author_name, article.author_url)], :class => 'author') +
        content_tag('span', comments, :class => 'comments'),
        :class => 'created-at'
      )
    end
    title
  end

  def comment_actions(comment)
    url = url_for(:profile => profile.identifier, :controller => :comment, :action => :check_actions, :id => comment.id)
    links = links_for_comment_actions(comment)
    content_tag(:li, link_to(content_tag(:span, _('Contents menu')), '#', :onclick => "toggleSubmenu(this,'',#{links.to_json}); return false", :class => 'menu-submenu-trigger comment-trigger', :url => url), :class=> 'vcard') unless links.empty?
  end

  private

  def links_for_comment_actions(comment)
    actions = [link_for_report_abuse(comment), link_for_spam(comment), link_for_edit(comment), link_for_remove(comment)]
    @plugins.dispatch(:comment_actions, comment).collect do |action|
      actions << (action.kind_of?(Proc) ? self.instance_eval(&action) : action)
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
        {:link => link_to_function(_('Mark as NOT SPAM'), 'remove_comment(this, %s); return false;' % url_for(:profile => profile.identifier, :mark_comment_as_ham => comment.id).to_json, :class => 'comment-footer comment-footer-link comment-footer-hide')}
      else
        {:link => link_to_function(_('Mark as SPAM'), 'remove_comment(this, %s, %s); return false;' % [url_for(:profile => profile.identifier, :controller => 'comment', :action => :mark_as_spam, :id => comment.id).to_json, _('Are you sure you want to mark this comment as SPAM?').to_json], :class => 'comment-footer comment-footer-link comment-footer-hide')}
      end
    end
  end

  def link_for_edit(comment)
    if comment.can_be_updated_by?(user)
      {:link => expirable_comment_link(comment, :edit, _('Edit'), url_for(:profile => profile.identifier, :controller => :comment, :action => :edit, :id => comment.id),:class => 'colorbox')}
    end
  end

  def link_for_remove(comment)
    if comment.can_be_destroyed_by?(user)
      {:link => link_to_function(_('Remove'), 'remove_comment(this, %s, %s); return false ;' % [url_for(:profile => profile.identifier, :controller => 'comment', :action => :destroy, :id => comment.id).to_json, _('Are you sure you want to remove this comment and all its replies?').to_json], :class => 'comment-footer comment-footer-link comment-footer-hide remove-children')}
    end
  end

end
