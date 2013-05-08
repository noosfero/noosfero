class FilePresenter::Video < FilePresenter
  def initialize(f)
    @file = f
  end

  def self.accepts?(f)
    return nil if f.content_type.nil?
    ( f.content_type[0..4] == 'video' ) ? 10 : nil
  end
end
