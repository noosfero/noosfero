class AbuseComplaint < Task
  has_many :abuse_reports, :dependent => :destroy
  belongs_to :reported, :class_name => "Profile", :foreign_key => "requestor_id"

  validates_presence_of :reported
  alias :requestor :reported

  def initialize(*args)
    super
    self.status = (args.first ? args.first[:status] : nil) || Task::Status::HIDDEN
  end

  after_update do |abuse_complaint|
    if abuse_complaint.reported.environment.reports_lower_bound < abuse_complaint.abuse_reports.count && abuse_complaint.status == Task::Status::HIDDEN
      abuse_complaint.activate
    end
  end

  def target
    reported.environment
  end

  def environment
    target
  end

  def title
    abuse_reports.count > 1 ? (_('Abuse complaint (%s)') % abuse_reports.count) :_('Abuse complaint')
  end

  def linked_subject
    {:text => reported.name, :url => reported.url}
  end

  def information
    {:message => _('%{linked_subject} was reported due to inappropriate behavior.')}
  end

  def accept_details
    true
  end

  def reject_details
    true
  end

  def icon
    {:type => :profile_image, :profile => reported, :url => reported.url}
  end

  def default_decision
    'skip'
  end

  def perform
    reported.disable
  end

  def task_activated_message
    _('Your profile was reported by the users of %s due to inappropriate behavior. The administrators of the environment are now reviewing the report. To solve this misunderstanding, please contact the administrators.') % environment.name
  end

  def task_finished_message
    _('Your profile was disabled by the administrators of %s due to inappropriate behavior. To solve this misunderstanding please contact them.') % environment.name
  end

  def target_notification_description
    _('%s was reported due to inappropriate behavior.') % reported.name
  end

  def target_notification_message
    _('The users of %{environment} reported %{reported} due to inappropriate behavior. A task was created with all the reports including the reasons and contents reported by these users. Please verify the reports and decide whether this profile must be disabled or not.') % {:environment => environment.name, :reported => reported.name}
  end

end
