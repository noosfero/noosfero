module Human
  extend ActiveSupport::Concern

  included do
    has_many :comments, :as => :author, :foreign_key => :author_id
    has_many :abuse_reports, :as => :reporter, :foreign_key => 'reporter_id', :dependent => :destroy

    scope :abusers, -> {
      joins(:abuse_complaints).where('tasks.status = 3').distinct.select("#{self.table_name}.*")
    }
    scope :non_abusers, -> {
      distinct.select("#{self.table_name}.*").
      joins("LEFT JOIN tasks ON #{self.table_name}.id = tasks.requestor_id AND tasks.type='AbuseComplaint'").
      where("tasks.status != 3 OR tasks.id is NULL")
    }
  end

  def already_reported?(profile)
    abuse_reports.any? { |report| report.abuse_complaint.reported == profile && report.abuse_complaint.opened? }
  end

  def register_report(abuse_report, profile)
    AbuseComplaint.create!(:reported => profile, :target => profile.environment) if !profile.opened_abuse_complaint
    abuse_report.abuse_complaint = profile.opened_abuse_complaint
    abuse_report.reporter = self
    abuse_report.save!
  end

  def abuser?
    AbuseComplaint.finished.where(:requestor_id => self).count > 0
  end

  # Sets the identifier for this person. Raises an exception when called on a
  # existing person (since peoples' identifiers cannot be changed)
  def identifier=(value)
    unless self.new_record?
      raise ArgumentError.new(_('An existing person cannot be renamed.'))
    end
    self[:identifier] = value
  end

end
