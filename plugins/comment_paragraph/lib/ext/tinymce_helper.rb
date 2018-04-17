require_dependency 'tinymce_helper'

module TinymceHelper

  def tinymce_init_js_with_comment_paragraph(options = {})
    options = options.merge(:keep_styles => false) if environment.plugin_enabled?(CommentParagraphPlugin)
    tinymce_init_js_without_comment_paragraph(options)
  end

  alias_method :tinymce_init_js_without_comment_paragraph, :tinymce_init_js
  alias_method :tinymce_init_js, :tinymce_init_js_with_comment_paragraph
end
