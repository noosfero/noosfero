class CommunityTrackPlugin::Step < Folder

  settings_items :hidden, :type => :boolean, :default => false

  alias :tools :children

  acts_as_list  :scope => :parent

  def belong_to_track
    errors.add(:parent, "Step not allowed at this parent.") if !parent.kind_of?(CommunityTrackPlugin::Track)
  end

  validate :belong_to_track
  validates_presence_of :start_date, :end_date
  validate :end_date_equal_or_after_start_date
  
  after_save :schedule_activation

  before_create do |step|
    step.published = false
    true
  end

  before_create :set_hidden_position
  before_save :set_hidden_position
  
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
    false
  end

  def enabled_tools
    {TinyMceArticle => {:name => _('Article')}, Forum => {:name => _('Forum')}}
  end

  def to_html(options = {})
    step = self
    lambda do
      render :file => 'content_viewer/step.rhtml', :locals => {:step => step}
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
    return if !changes['start_date'] && !changes['end_date'] && !changes['published']
    today = Date.today
    if today <= end_date || published
      schedule_date = !published ? start_date : end_date + 1.day
      CommunityTrackPlugin::ActivationJob.find(id).destroy_all
      Delayed::Job.enqueue(CommunityTrackPlugin::ActivationJob.new(self.id), 0, schedule_date)
    end
  end

  def publish
    self[:published] = active? && !hidden
    save!
  end

  class CommunityTrackPlugin::ActivationJob < Struct.new(:step_id)

    def self.find(step_id)
      Delayed::Job.where(:handler => "--- !ruby/struct:CommunityTrackPlugin::ActivationJob \nstep_id: #{step_id}\n")
    end

    def perform
      step = CommunityTrackPlugin::Step.find(step_id)
      step.publish
    end

  end

end
