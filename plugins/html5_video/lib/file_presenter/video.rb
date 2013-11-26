class FilePresenter::Video < FilePresenter
  def self.accepts?(f)
    return nil if !f.respond_to?(:content_type) || f.content_type.nil?
    ( f.content_type[0..4] == 'video' ) ? 10 : nil
  end

  def short_description
    _('Video (%s)') % content_type.split('/')[1].upcase
  end
end
