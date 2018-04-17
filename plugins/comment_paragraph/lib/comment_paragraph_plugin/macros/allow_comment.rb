class Application < Rails::Application
  config.action_view.sanitized_allowed_attributes << 'data-macro-paragraph_uuid' unless config.action_view.sanitized_allowed_attributes.include?('data-macro-paragraph_uuid')
end

class CommentParagraphPlugin::AllowComment < Noosfero::Plugin::Macro
  def self.configuration
    { params: [],
      skip_dialog: true,
      generator: 'makeCommentable();',
      js_files: 'macro/allow_comment.js',
      title: _('Select/Deselect section as commentable'),
      icon_path: '/designs/icons/tango/Tango/16x16/actions/comment.png',
      css_files: 'macro/allow_comment.css' }
  end

  def parse(params, inner_html, source)
    paragraph_uuid = params[:paragraph_uuid]
    article = source
    @paragraph_comments_counts ||= article.paragraph_comments.without_spam.group(:paragraph_uuid).reorder(:paragraph_uuid).count
    count = @paragraph_comments_counts.fetch(paragraph_uuid, 0)
    classes = params[:classes]

    proc {
      if controller.kind_of?(ContentViewerController) &&
         article.comment_paragraph_plugin_enabled?
        render partial: 'comment_paragraph_plugin_profile/comment_paragraph',
               locals: { paragraph_uuid: paragraph_uuid, article_id: article.id,
                         inner_html: inner_html, count: count, classes: classes,
                         profile_identifier: article.profile.identifier }
      else
        inner_html
      end
    }
  end
end
