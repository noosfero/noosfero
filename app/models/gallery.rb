class Gallery < Folder

  def self.short_description
    _('Gallery')
  end

  def self.description
    _('A gallery, inside which you can put images.')
  end

  include ActionView::Helpers::TagHelper
  def to_html(options)
    article = self
    lambda do
      render :file => 'content_viewer/image_gallery', :locals => {:article => article}
    end
  end

  def gallery?
    true
  end

end
