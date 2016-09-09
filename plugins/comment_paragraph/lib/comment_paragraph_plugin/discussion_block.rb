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
    current_time = Time.now
    discussions = holder.articles.where(type: VALID_CONTENT).order('start_date ASC, end_date ASC, created_at DESC').limit(self.total_items)
    case discussion_status
    when STATUS_NOT_OPENED
      discussions = discussions.where("start_date > ?", current_time)
    when STATUS_AVAILABLE
      discussions = discussions.where("start_date is null or start_date <= ?", current_time)
      discussions = discussions.where("end_date is null or end_date >= ?", current_time)
    when STATUS_CLOSED
      discussions = discussions.where("end_date < ?", current_time)
    end
    discussions
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

  def api_content
    Api::Entities::ArticleBase.represent(self.discussions).as_json
  end

  def display_api_content_by_default?
    false
  end
end
