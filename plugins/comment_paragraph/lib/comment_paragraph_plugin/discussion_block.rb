class CommentParagraphPlugin::DiscussionBlock < Block

  settings_items :presentation_mode, :type => String, :default => 'title_only'
  settings_items :total_items, :type => Integer, :default => 5
  settings_items :fixed_documents_ids, :type => Array, :default => []
  settings_items :discussion_status, :type => Integer
  settings_items :use_portal_community, :type => :boolean, :default => false

  attr_accessible :presentation_mode, :discussion_status, :use_portal_community, :total_items

  DISCUSSION = ['CommentParagraphPlugin::Discussion']

  STATUS_NOT_OPENED = 0
  STATUS_AVAILABLE = 1
  STATUS_CLOSED = 2

  def self.description
    c_('Discussion Articles')
  end

  def help
    _("This block displays all profile's article discussion")
  end

  def discussions(person = nil)
    amount = self.total_items - self.fixed_documents_ids.length
    if(amount <= 0 )
      return [];
    end
    current_time = Time.now
    return [] if holder.blank?
    discussions = holder.articles.accessible_to(person).where(type: DISCUSSION).order('start_date DESC, end_date ASC, created_at DESC').limit(amount)
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

  def fixed_documents
    holder.articles.where(type: DISCUSSION, id: self.fixed_documents_ids).order('start_date DESC, end_date ASC, created_at DESC')
  end

  def holder
    return nil if self.box.nil? || self.box.owner.nil?
    if environment_owner?
      use_portal_community ? self.box.owner.portal_community : self.box.owner
    else
      self.box.owner
    end
  end

  def mode?(attr)
    attr == self.presentation_mode
  end

  def api_content(params = {})
    {
      articles: Api::Entities::ArticleBase.represent(self.discussions(params[:current_person])),
      fixed_documents: Api::Entities::ArticleBase.represent(self.fixed_documents),
      total_items: self.total_items,
      discussion_status: self.discussion_status
    }.as_json
  end

  def api_content= params
    super
    self.total_items= params[:total_items]
    self.fixed_documents_ids= params[:fixed_documents_ids]
  end

  def display_api_content_by_default?
    false
  end

  def environment_owner?
    self.box.owner.kind_of?(Environment)
  end
end
