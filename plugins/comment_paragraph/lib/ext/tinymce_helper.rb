require_dependency 'tinymce_helper'

module TinymceHelper

  def tinymce_editor_with_comment_paragraph(options = {})
    options = options.merge(:keep_styles => false) if environment.plugin_enabled?(CommentParagraphPlugin)
    tinymce_editor_without_comment_paragraph(options)
  end

  alias_method :tinymce_editor_without_comment_paragraph, :tinymce_editor
  alias_method :tinymce_editor, :tinymce_editor_with_comment_paragraph
end
