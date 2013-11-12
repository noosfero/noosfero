class Forum < Folder

  acts_as_having_posts :order => 'updated_at DESC'
  include PostsLimit

  settings_items :terms_of_use, :type => :string, :default => ""
  settings_items :has_terms_of_use, :type => :boolean, :default => false
  has_and_belongs_to_many :users_with_agreement, :class_name => 'Person', :join_table => 'terms_forum_people'

  def self.type_name
    _('Forum')
  end

  def self.short_description
    _('Forum')
  end

  def self.description
    _('An internet forum, also called message board, where discussions can be held.')
  end

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/forum_page'
    end
  end

  def forum?
    true
  end

  def self.icon_name(article = nil)
    'forum'
  end

  def notifiable?
    true
  end

  def first_paragraph
    return '' if body.blank?
    paragraphs = Hpricot(body).search('p')
    paragraphs.empty? ? '' : paragraphs.first.to_html
  end

  def add_agreed_user(user)
    self.users_with_agreement << user
    self.save
  end

  def agrees_with_terms?(user)
    return true unless self.has_terms_of_use
    if user
      self.users_with_agreement.find_by_id user.id
    else
      false
    end
  end

end
