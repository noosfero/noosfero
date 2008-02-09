module BlockHelper

  def block_title(title)
    content_tag('h3', title, :class => 'block-title')
  end

end
