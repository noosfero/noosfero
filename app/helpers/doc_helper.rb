module DocHelper
  def display_doc(text)
    content_tag(
      'div',
      wrap_main_content(
        render(:partial => 'path') +
        content_tag(
          'div',
          text,
          :id => 'online-doc-text'
        )
      ),
      :id => 'online-doc'
    )
  end
end
