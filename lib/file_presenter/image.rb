class FilePresenter::Image < FilePresenter
  def initialize(f)
    @file = f
  end

  def self.accepts?(f)
    f.image? ? 10 : nil
  end

  def icon_name
    public_filename :icon
  end

  def short_description
    _('Image (%s)') % content_type.split('/')[1].upcase
  end
end
