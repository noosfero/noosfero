class CustomFormsPlugin::Form < ApplicationRecord

  belongs_to :profile

  has_many :fields, -> { order 'position' },
    class_name: 'CustomFormsPlugin::Field', dependent: :destroy
  accepts_nested_attributes_for :fields, :allow_destroy => true

  has_many :submissions,
    :class_name => 'CustomFormsPlugin::Submission', :dependent => :destroy

  serialize :access

  validates_presence_of :profile, :name, :identifier
  validates_uniqueness_of :slug, :scope => :profile_id
  validates_uniqueness_of :identifier, :scope => :profile_id
  validate :period_range,
    :if => Proc.new { |f| f.begining.present? && f.ending.present? }
  validate :access_format
  validate :valid_poll_alternatives

  # We are using a belongs_to relation, to avoid change the UploadedFile schema.
  # With the belongs_to instead of the has_one, we keep the change only on the
  # CustomFormsPlugin::Form schema.
  belongs_to :article, :class_name => 'UploadedFile', dependent: :destroy

  attr_accessible :name, :profile, :for_admission, :access, :begining, :kind,
                  :ending, :description, :fields_attributes, :profile_id,
                  :on_membership, :identifier, :access_result_options, :image

  attr_accessor :remove_image

  KINDS = %w(survey poll)
  # Dynamic Translations
  _('Survey')
  _('Surveys')
  _('survey')
  _('surveys')
  _('Poll')
  _('Polls')
  _('poll')
  _('polls')

  validates :kind, inclusion: { in: KINDS, message: _("%{value} is not a valid kind.") }

  SEARCHABLE_FIELDS = {
    :name => {:label => _('Name'), :weight => 10},
    :slug => {:label => _('Slug'), :weight => 5},
    :identifier => {:label => _('identifier'), :weight => 5},
    :description => {:label => _('Description'), :weight => 3},
  }

  before_validation do |form|
    form.slug = form.name.to_slug if form.name.present?
    form.identifier = form.slug unless form.identifier.present?
    form.access = nil if form.access.blank?
  end

  after_destroy do |form|
    tasks = CustomFormsPlugin::MembershipSurvey.opened.select { |t| t.form_id == form.id }
    tasks.each {|task| task.cancel}
  end

  scope :from_profile, -> profile { where profile_id: profile.id }
  scope :on_memberships, -> { where on_membership: true, for_admission: false }
  scope :for_admissions, -> { where for_admission: true }
  scope :by_kind, -> kind { where kind: kind.to_s }

  scope :closed, -> { where('ending <= ?', DateTime.now) }
  scope :not_open_yet, -> { where('begining > ?', DateTime.now) }
  scope :not_closed, -> { where('(begining < ? OR begining IS NULL) AND '\
                          '(ending > ? OR ending IS NULL)',
                          DateTime.now, DateTime.now) }

  scope :with_public_results, -> { where access_result_options: "public" }
  scope :with_private_results, -> { where access_result_options: "private" }
  scope :with_public_results_after_ends, -> { where access_result_options: "public_after_ends" }
  scope :by_status, -> status {
    case status
    when 'opened'
      where('(begining IS NULL OR begining <= ?) AND (ending IS NULL OR ending > ?)', Time.now, Time.now)
    when 'closed'
      where('ending IS NOT NULL AND ending < ?', Time.now)
    when 'to-come'
      where('begining IS NOT NULL AND begining > ?', Time.now)
    end
  }

  def expired?
    (begining.present? && Time.now < begining) || (ending.present? && Time.now > ending)
  end

  def will_open?
    begining.present? && Time.now < begining
  end

  def accessible_to(target)
    return true if access.nil? || target == profile
    return false if target.nil?
    return true if access == 'logged'
    return true if access == 'associated' && ((profile.organization? && profile.members.include?(target)) || (profile.person? && profile.friends.include?(target)))
    return true if access.kind_of?(Integer) && target.id == access
    return true if access.kind_of?(Array) && access.include?(target.id)
  end

  def image
    self.article
  end

  def image=(uploaded_file)
    self.article = uploaded_file
  end

  def duration_in_days
    if begining == nil and ending == nil
      return "This query has no ending date"
    end
    seconds_to_days = 86400
    days = (ending.to_i - begining.to_i) / seconds_to_days
    if days < 1
      return "Ends today."
    end

    if days >= 1 && days < 2
      return "Ends tomorow."
    end

    if days < 0
      return "Already closed"
    end

    return "#{days} days left"
  end

  def status
    if begining.try(:future?)
      'Not open yet'
    elsif ending.try(:future?) && (ending < 3.days.from_now)
      'Closing soon'
    elsif ending.nil? || ending.try(:future?)
      'Open'
    else
      'Closed'
    end
  end

  def submission_by(person)
    if person.present?
      subm = submissions.find_by(form_id: self.id, profile_id: person.id)
    end
    subm || CustomFormsPlugin::Submission.new(form: self, profile: person)
  end

  def results
    CustomFormsPlugin::Graph.new(self).query_results
  end

  alias_attribute :result_access, :access_result_options

  def show_results_for(person)
    result_access.blank? ||
    (result_access == 'public') ||
    ((result_access == 'public_after_ends') && ending.present? &&
                                              (ending < DateTime.now)) ||
    ((result_access == 'private') && (person == profile ||
                                      person.in?(profile.admins) ||
                                      person.in?(profile.environment.admins)))
  end

  private

  def access_format
    if access.present?
      if access.kind_of?(String)
        if access != 'logged' && access != 'associated'
          errors.add(:access, _('Invalid string format of access.'))
        end
      elsif access.kind_of?(Integer)
        if !Profile.exists?(access)
          errors.add(:access, _('There is no profile with the provided id.'))
        end
      elsif access.kind_of?(Array)
        access.each do |value|
          if !value.kind_of?(Integer) || !Profile.exists?(value)
            errors.add(:access, _('There is no profile with the provided id.'))
            break
          end
        end
      else
        errors.add(:access, _('Invalid type format of access.'))
      end
    end
  end

  def period_range
    errors.add(:base, _('The time range selected is invalid.')) if ending < begining
  end

  def valid_poll_alternatives
    if kind == "poll" && fields.first.present? && fields.first.alternatives.size < 2
      errors.add(:poll_alternatives, _('can\'t be less than 2'))
      false
    end
    true
  end
end
