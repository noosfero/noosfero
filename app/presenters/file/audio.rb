class FilePresenter::Audio < FilePresenter
  def self.accepts?(f)
    return nil if !f.respond_to?(:content_type) || f.content_type.nil?
    ( f.content_type[0..4] == 'audio' ) ? 5 : nil
  end

  def sized_icon(size)
    public_filename size
  end

  def icon_name
    public_filename :icon
  end

  def short_description
    _('Audio (%s)') % content_type.split('/')[1].upcase
  end

  #Overwriting method from FilePresenter to allow download of images
  def download?(view = nil)
    view.blank? || view == 'false'
  end
end
