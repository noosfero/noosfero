require_dependency 'tinymce_helper'

module TinymceHelper

  def tinymce_editor_with_comment_paragraph(options = {})
    options = options.merge(:keep_styles => false) if environment.plugin_enabled?(CommentParagraphPlugin)
    tinymce_editor_without_comment_paragraph(options)
  end

  alias_method_chain :tinymce_editor, :comment_paragraph
end
