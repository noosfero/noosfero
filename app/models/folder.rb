class Folder < Article

  acts_as_having_settings :field => :setting

  settings_items :view_as, :type => :string, :default => 'folder'

  def self.select_views
    [[_('Folder'), 'folder'], [_('Image gallery'), 'image_gallery']]
  end

  def self.views
    select_views.map(&:last)
  end

  validates_inclusion_of :view_as, :in => self.views

  def self.short_description
    _('Folder')
  end

  def self.description
    _('A folder, inside which you can put other articles.')
  end

  def icon_name
    'folder'
  end

  # FIXME isn't this too much including just to be able to generate some HTML?
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include ActionView::Helpers::AssetTagHelper
  include FolderHelper
  include DatesHelper

  def to_html(options = {})
    send(view_as)
  end

  def folder
    content_tag('div', body) + tag('hr') + (children.empty? ? content_tag('em', _('(empty folder)')) : list_articles(children))
  end

  def image_gallery
    article = self
    lambda do
      render :file => 'content_viewer/image_gallery', :locals => {:article => article}
    end
  end

  def folder?
    true
  end

  def display_as_gallery?
    view_as == 'image_gallery'
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

  has_many :images, :class_name => 'Article',
                    :foreign_key => 'parent_id',
                    :order => 'articles.type, articles.name',
                    :include => :reference_article,
                    :conditions => ["articles.type = 'UploadedFile' and articles.content_type in (?) or articles.type = 'Folder' or (articles.type = 'PublishedArticle' and reference_articles_articles.type = 'UploadedFile' and reference_articles_articles.content_type in (?))", UploadedFile.content_types, UploadedFile.content_types]

end
