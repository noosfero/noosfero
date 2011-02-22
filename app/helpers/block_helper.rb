module BlockHelper

  def block_title(title)
    tag_class = 'block-title'
    tag_class += ' empty' if title.empty?
    content_tag 'h3', content_tag('span', title), :class => tag_class
  end

end
