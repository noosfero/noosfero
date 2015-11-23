ActionView::Base.sanitized_allowed_attributes += ['data-macro', 'data-macro-paragraph_uuid']

class CommentParagraphPlugin::AllowComment < Noosfero::Plugin::Macro

  def self.configuration
    { :params => [] }
  end

  def parse(params, inner_html, source)
    paragraph_uuid = params[:paragraph_uuid]
    article = source
    count = article.paragraph_comments.without_spam.in_paragraph(paragraph_uuid).count

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
