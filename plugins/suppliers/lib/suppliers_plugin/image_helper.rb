module SuppliersPlugin::ImageHelper

  # image that can be aligned, centered, and resized with aspect ratio
  def profile_link_with_image profile, size=:portrait, options={}
    options[:class] = "#{options[:class] || ''} inner"
    options[:style] = "#{options[:style] || ''}; background-image: url(#{profile_icon profile, size})"

    link = link_to '', profile.url, options
    content_tag 'div', link, :class => "profile-image #{size}"
  end

end
