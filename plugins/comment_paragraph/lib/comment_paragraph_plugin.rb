class CommentParagraphPlugin < Noosfero::Plugin
  def self.plugin_name
    "Comment Paragraph"
  end

  def self.plugin_description
    _("A plugin that display comments divided by paragraphs.")
  end

  def unavailable_comments(scope)
    scope.without_paragraph
  end

  def comment_form_extra_contents(args)
    comment = args[:comment]
    paragraph_uuid = comment.paragraph_uuid || args[:paragraph_uuid]
    proc {
      arr = []
      arr << hidden_field_tag("comment[id]", comment.id)
      arr << hidden_field_tag("comment[paragraph_uuid]", paragraph_uuid) if paragraph_uuid
      arr << hidden_field_tag("comment[comment_paragraph_selected_area]", comment.comment_paragraph_selected_area) unless comment.comment_paragraph_selected_area.blank?
      arr << hidden_field_tag("comment[comment_paragraph_selected_content]", comment.comment_paragraph_selected_content) unless comment.comment_paragraph_selected_content.blank?
      arr
    }
  end

  def comment_extra_contents(args)
    comment = args[:comment]
    proc {
      render file: "comment_paragraph_plugin_profile/comment_extra", locals: { comment: comment }
    }
  end

  def js_files
    ["comment_paragraph_macro", "rangy-core", "rangy-cssclassapplier", "rangy-serializer"]
  end

  def stylesheet?
    true
  end

  def self.activation_mode_default_setting
    "manual"
  end

  def article_extra_toolbar_buttons(article)
    user = context.send :user
    return [] unless article.comment_paragraph_plugin_enabled? && article.allow_edit?(user) && article.kind_of?(CommentParagraphPlugin::Discussion)

    buttons = []

    buttons << { title: _("Export Comments"),
                 url: { controller: "comment_paragraph_plugin_profile",
                        profile: article.profile.identifier,
                        action: "export_comments",
                        id: article.id },
                 icon: "download" }
    buttons
  end

  def self.api_mount_points
    [CommentParagraphPlugin::API]
  end

  def self.extra_blocks
    {
      CommentParagraphPlugin::DiscussionBlock => { position: ["1", "2", "3"] }
    }
  end

  def content_types
    [CommentParagraphPlugin::Discussion]
  end
end

require_dependency "comment_paragraph_plugin/macros/allow_comment"
