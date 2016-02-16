class Folder < Article

  def self.type_name
    _('Folder')
  end

  validate :not_belong_to_blog

  def not_belong_to_blog
    errors.add(:parent, "A folder should not belong to a blog.") if parent && parent.blog?
  end

  acts_as_having_settings :field => :setting

  xss_terminate :only => [ :name, :body ], :with => 'white_list', :on => 'validation'

  include WhiteListFilter
  filter_iframes :body
  def iframe_whitelist
    profile && profile.environment && profile.environment.trusted_sites_for_iframe
  end

  def self.short_description
    _('Folder')
  end

  def self.description
    _('A folder, inside which you can put other articles.')
  end

  def self.icon_name(article = nil)
    'folder'
  end

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    folder = self
    proc do
      render :file => 'content_viewer/folder', :locals => {:folder => folder}
    end
  end

  def folder?
    true
  end

  def can_display_hits?
    false
  end

  def accept_comments?
    false
  end

  def news(limit = 30, highlight = false)
    profile.recent_documents(limit, ["articles.type != ? AND articles.highlighted = ? AND articles.parent_id = ?", 'Folder', highlight, id])
  end

  has_many :images, -> {
    order('articles.type, articles.name').
    where("articles.type = 'UploadedFile' and articles.content_type in (?) or articles.type in ('Folder','Gallery')", UploadedFile.content_types)
  }, class_name: 'Article', foreign_key: 'parent_id'


  def accept_uploads?
    !self.has_posts? || self.gallery?
  end

end
