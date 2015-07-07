class FilePresenter::Image < FilePresenter
  def self.accepts?(f)
    return nil unless f.respond_to? :image?
    f.image? ? 10 : nil
  end

  def sized_icon(size)
    public_filename size
  end

  def icon_name
    public_filename :icon
  end

  def short_description
    _('Image (%s)') % content_type.split('/')[1].upcase
  end

  #Overwriting method from FilePresenter to allow download of images
  def download?(view = nil)
    view.blank? || view == 'false'
  end
end
