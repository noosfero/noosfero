require_dependency 'comment_group_macro_plugin/ext/article'
require_dependency 'comment_group_macro_plugin/ext/comment'

#FIXME See a better way to generalize this parameter.
ActionView::Base.sanitized_allowed_attributes += ['data-macro', 'data-macro-group_id']

class CommentGroupMacroPlugin < Noosfero::Plugin

  def self.plugin_name
    "Comment Group"
  end

  def self.plugin_description
    _("A plugin that display comment groups.")
  end

  def load_comments(article)
    article.comments.without_spam.without_group.as_thread
  end

  #FIXME make this test
  def macro_display_comments(params, inner_html, source)
    group_id = params[:group_id].to_i
    article = source
    count = article.group_comments.without_spam.in_group(group_id).count

    lambda {render :partial => 'plugins/comment_group_macro/views/comment_group.rhtml', :locals => {:group_id => group_id, :article_id => article.id, :inner_html => inner_html, :count => count, :profile_identifier => article.profile.identifier }}
  end

  def macro_methods
    'macro_display_comments'
  end

  def config_macro_display_comments
    { :params => [], :skip_dialog => true, :generator => 'makeCommentable();', :js_files => 'comment_group.js', :icon_path => '/designs/icons/tango/Tango/16x16/emblems/emblem-system.png', :css_files => 'comment_group.css' }
  end

  def comment_form_extra_contents(args)
    comment = args[:comment]
    group_id = comment.group_id || args[:group_id]
    lambda {
      hidden_field_tag('comment[group_id]', group_id) if group_id
    }
  end

  def js_files
    'comment_group_macro.js'
  end

end
