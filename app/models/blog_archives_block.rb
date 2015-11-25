class BlogArchivesBlock < Block

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::AssetTagHelper
  include DatesHelper

  def self.description
    _('Blog posts')
  end

  def default_title
    _('Blog posts')
  end

  settings_items :blog_id, type: Integer

  def blog
    blog_id && owner.blogs.exists?(blog_id) ? owner.blogs.find(blog_id) : owner.blog
  end

  def content(args={})
    return nil unless self.blog
    block = self
    proc do
      render :file => 'blocks/blog_archives', :locals => { :block => block }
    end
  end

  def self.expire_on
      { :profile => [:article], :environment => [:article] }
  end
end
