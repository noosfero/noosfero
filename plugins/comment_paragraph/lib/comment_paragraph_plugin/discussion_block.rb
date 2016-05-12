class CommentParagraphPlugin::DiscussionBlock < Block

  settings_items :presentation_mode, :type => String, :default => 'title_only'
  settings_items :total_items, :type => Integer, :default => 5
  settings_items :discussion_status, :type => Integer

  attr_accessible :presentation_mode, :total_items, :discussion_status

  VALID_CONTENT = ['CommentParagraphPlugin::Discussion']

  STATUS_NOT_OPENED = 0
  STATUS_AVAILABLE = 1
  STATUS_CLOSED = 2

  def self.description
    c_('Discussion Articles')
  end

  def help
    _("This block displays all profile's article discussion")
  end

  def discussions
    holder.articles.where(type: VALID_CONTENT).order('created_at DESC').limit(self.total_items)
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

  def mode?(attr)
    attr == self.presentation_mode
  end

end
