# FIXME See a better way to generalize this parameter.
Loofah::HTML5::WhiteList::ALLOWED_ATTRIBUTES.merge %w[data-macro data-macro-group_id]

class CommentParagraphPlugin::AllowComment < Noosfero::Plugin::Macro

  def self.configuration
    { :params => [] }
  end

  def parse(params, inner_html, source)
    paragraph_uuid = params[:paragraph_uuid]
    article = source
    @paragraph_comments_counts ||= article.paragraph_comments.without_spam.group(:paragraph_uuid).reorder(:paragraph_uuid).count
    count = @paragraph_comments_counts.fetch(paragraph_uuid, 0)

    proc {
      if controller.kind_of?(ContentViewerController) && article.comment_paragraph_plugin_activated?
        render :partial => 'comment_paragraph_plugin_profile/comment_paragraph',
               :locals => {:paragraph_uuid => paragraph_uuid, :article_id => article.id, :inner_html => inner_html, :count => count, :profile_identifier => article.profile.identifier }
      else
        inner_html
      end
    }
  end
end
