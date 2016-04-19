module ContextContentBlockHelper
  def content_image(content)
    if content.image?
      image_tag(content.public_filename(:thumb))
    else
      extra_class = content.uploaded_file? ? "extension-#{content.extension}" : ''
      klasses = [content.icon_name].flatten.map{|name| 'icon-'+name}.join(' ')
      content_tag 'div', '', :class => "context-icon #{klasses} #{extra_class}"
    end
  end
end
