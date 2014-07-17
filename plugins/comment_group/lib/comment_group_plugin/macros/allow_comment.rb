#FIXME See a better way to generalize this parameter.
ActionView::Base.sanitized_allowed_attributes += ['data-macro', 'data-macro-group_id']

class CommentGroupPlugin::AllowComment < Noosfero::Plugin::Macro
  def self.configuration
    { :params => [],
      :skip_dialog => true,
      :generator => 'makeCommentable();',
      :js_files => 'comment_group.js',
      :icon_path => '/designs/icons/tango/Tango/16x16/emblems/emblem-system.png',
      :css_files => 'comment_group.css' }
  end

  def parse(params, inner_html, source)
    group_id = params[:group_id].to_i
    article = source
    count = article.group_comments.without_spam.in_group(group_id).count

    proc {
      render :partial => 'comment_group_plugin_profile/comment_group',
             :locals => {:group_id => group_id, :article_id => article.id, :inner_html => inner_html, :count => count, :profile_identifier => article.profile.identifier }
    }
  end
end
