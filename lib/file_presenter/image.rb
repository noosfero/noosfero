class FilePresenter::Image < FilePresenter
  def initialize(f)
    @file = f
  end

  def self.accepts?(f)
    f.image? ? 10 : nil
  end

  def icon_name
    article.public_filename :icon
  end
end
