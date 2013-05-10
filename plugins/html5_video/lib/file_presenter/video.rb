class FilePresenter::Video < FilePresenter
  def initialize(f)
    @file = f
  end

  def self.accepts?(f)
    return nil if f.content_type.nil?
    ( f.content_type[0..4] == 'video' ) ? 10 : nil
  end

  def short_description
    _('Video (%s)') % content_type.split('/')[1].upcase
  end
end
