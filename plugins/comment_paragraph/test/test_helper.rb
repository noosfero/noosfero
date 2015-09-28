require_relative '../../../test/test_helper'

def assert_mark_paragraph(html, tag, content)
  assert_tag_in_string html, :tag => tag, :child => {:tag => 'span', :attributes => {'data-macro'=>"comment_paragraph_plugin/allow_comment"}, :content => content}
end
