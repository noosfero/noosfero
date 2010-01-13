class SlideshowBlock < Block

  settings_items :gallery_id, :type => 'integer'
  settings_items :interval, :type => 'integer', :default => 4

  def self.description
    _('Display images from gallery as slideshow')
  end

  def gallery
    gallery_id ? Folder.find(gallery_id) : nil
  end

  def content
    if gallery
      images = gallery.images
      block_id = id
      block_title = title
      lambda do
        block_title(block_title) +
        content_tag('div',
          images.map do |i|
            link_to(
              content_tag('div', '', :style => "background-image: url(#{i.public_filename(:thumb)})"),
              (i.external_link || i.view_url), :target => '_blank'
            )
          end.join("\n"),
          :class => 'slideshow-container'
        )
      end
    else
      lambda do
        content_tag('em', _('Please select a gallery to display its images.'))
      end
    end
  end

  def footer
    if gallery
      block_id = id
      interval_sec = interval * 1000
      lambda do
        javascript_tag("jQuery('#block-#{block_id} .slideshow-container').cycle({fx: 'fade', timeout: #{interval_sec}})")
      end
    end
  end

end
