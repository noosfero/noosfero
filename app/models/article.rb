class Article < ActiveRecord::Base

  belongs_to :profile
  validates_presence_of :profile_id, :name, :slug, :path

  acts_as_taggable  

  acts_as_filesystem

  acts_as_versioned

  # retrives all articles belonging to the given +profile+ that are not
  # sub-articles of any other article.
  def Article.top_level_for(profile)
    self.find(:all, :conditions => [ 'parent_id is null and profile_id = ?', profile.id ])
  end

  # produces the HTML code that is to be displayed as this article's contents.
  #
  # The implementation in this class just provides the +body+ attribute as the
  # HTML.  Other article types can override this method to provide customized
  # views of themselves.
  def to_html
    body
  end

  # provides the icon name to be used for this article. In this class this
  # method just returns 'text-html', but subclasses may (and should) override
  # to return their specific icons.
  def icon_name
    'text-html'
  end

  def mime_type
    'text/html'
  end

  def title
    name
  end

end
