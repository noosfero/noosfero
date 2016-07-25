class ProfileImagesPlugin::ProfileImagesBlock < Block
  attr_accessible :limit
  settings_items :limit, type: :integer, default: 6

  def view_title
    self.default_title
  end

  def images
    images = owner.articles.images
    self.limit.nil? ? images : images.first(self.get_limit)
  end

  def extra_option
    { }
  end

  def self.description
    _('Display the images inside the context where the block is available.')
  end

  def help
    _('This block lists the images inside this profile.')
  end

  def default_title
    _('Profile images')
  end

  def api_content
    content = []
    images.each do |image|
      content << { title: image.title, view_url: image.view_url, path: image.public_filename(:thumb), id: image.id }
    end
    { images: content }
  end

  def display_api_content_by_default?
    false
  end

  def timeout
    4.hours
  end

  def self.expire_on
    { profile: [:article] }
  end
end
