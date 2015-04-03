class CommunityTrackPlugin::Step < Folder

  settings_items :hidden, :type => :boolean, :default => false
  settings_items :tool_type, :type => String

  attr_accessible :start_date, :end_date, :tool_type, :hidden

  alias :tools :children

  acts_as_list  :scope => :parent

  def belong_to_track
    errors.add(:parent, _("Step not allowed at this parent.")) unless parent.kind_of?(CommunityTrackPlugin::Track)
  end

  validate :belong_to_track
  validates_presence_of :start_date, :end_date
  validate :end_date_equal_or_after_start_date

  after_save :schedule_activation

  before_create do |step|
    step.accept_comments = false
    true
  end

  before_create :set_hidden_position
  before_save :set_hidden_position

  def initialize(*args)
    super(*args)
    self.start_date ||= Date.today
    self.end_date ||= Date.today + 1.day
  end

  def set_hidden_position
    if hidden
      decrement_positions_on_lower_items
      self[:position] = 0
    elsif position == 0
      add_to_list_bottom
    end
  end

  def end_date_equal_or_after_start_date
    if end_date && start_date
      errors.add(:end_date, _('must be equal or after start date.')) unless end_date >= start_date
    end
  end

  def self.short_description
    _("Step")
  end

  def self.description
    _('Defines a step.')
  end

  def accept_comments?
    accept_comments
  end

  def self.enabled_tools
    [TinyMceArticle, Forum]
  end

  def to_html(options = {})
    step = self
    proc do
      render :file => 'content_viewer/step', :locals => {:step => step}
    end
  end

  def active?
    (start_date..end_date).include?(Date.today)
  end

  def finished?
    Date.today > end_date
  end

  def waiting?
    Date.today < start_date
  end

  def schedule_activation
    return if !changes['start_date'] && !changes['end_date']
    if Date.today <= end_date || accept_comments
      schedule_date = !accept_comments ? start_date : end_date + 1.day
      CommunityTrackPlugin::ActivationJob.find(id).destroy_all
      Delayed::Job.enqueue(CommunityTrackPlugin::ActivationJob.new(self.id), :run_at => schedule_date)
    end
  end

  def toggle_activation
    accept_comments = active?
    # set accept_comments = true on all children
    self.class.toggle_activation(self, accept_comments)
  end

  def self.toggle_activation(article, accept_comments)
    article.update_attribute(:accept_comments, accept_comments)
    article.children.each {|a| toggle_activation(a, accept_comments)}
  end

  def tool_class
    tool_type ? tool_type.constantize : nil
  end

  def tool
    tools.where(type: tool_type).first
  end

end
