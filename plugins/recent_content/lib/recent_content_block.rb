class RecentContentBlock < Block

  settings_items :presentation_mode, :type => String, :default => 'title_only'
  settings_items :total_items, :type => Integer, :default => 5
  settings_items :show_blog_picture, :type => :boolean, :default => false
  settings_items :selected_folder, :type => Integer

  attr_accessible :presentation_mode, :total_items, :show_blog_picture, :selected_folder

  VALID_CONTENT = ['RawHTMLArticle', 'TextArticle', 'TextileArticle', 'TinyMceArticle']

  def self.description
    c_('Recent content')
  end

  def help
    _('This block displays all articles inside the blog you choose. You can edit the block to select which of your blogs is going to be displayed in the block.')
  end

  def articles_of_folder(folder, limit)
   holder.articles.where(type: VALID_CONTENT, parent_id: folder.id).
     order('created_at DESC').limit(limit)
  end

  def holder
    return nil if self.box.nil? || self.box.owner.nil?
    if self.box.owner.kind_of?(Environment)
      return nil if self.box.owner.portal_community.nil?
      self.box.owner.portal_community
    else
      self.box.owner
    end
  end

  def parents
    selected = self.holder.articles.where(type: 'Blog').first
  end

  def root
    unless self.selected_folder.nil?
      holder.articles.where(id: self.selected_folder).first
    end
  end

  include DatesHelper

  def content(args={})
    block = self
    proc do
      render :file => 'blocks/recent_content_block', :locals => {:root => block.root, :block => block}
    end
  end

  def mode?(attr)
    attr == self.presentation_mode
  end

end
