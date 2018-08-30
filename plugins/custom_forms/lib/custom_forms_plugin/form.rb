class CustomFormsPlugin::Form < ApplicationRecord

  belongs_to :profile

  has_many :fields, -> { order 'custom_forms_plugin_fields.position' },
    class_name: 'CustomFormsPlugin::Field', dependent: :destroy
  accepts_nested_attributes_for :fields, :allow_destroy => true

  has_many :submissions,
    :class_name => 'CustomFormsPlugin::Submission', :dependent => :destroy

  validates_presence_of :profile, :name, :identifier
  validates_uniqueness_of :slug, :scope => :profile_id
  validates_uniqueness_of :identifier, :scope => :profile_id
  validate :period_range,
    :if => Proc.new { |f| f.begining.present? && f.ending.present? }
  validate :valid_poll_alternatives

  # We are using a belongs_to relation, to avoid change the UploadedFile schema.
  # With the belongs_to instead of the has_one, we keep the change only on the
  # CustomFormsPlugin::Form schema.
  belongs_to :article, :class_name => 'UploadedFile', dependent: :destroy

  attr_accessible :name, :profile, :for_admission, :access, :begining, :kind,
                  :ending, :description, :fields_attributes, :profile_id,
                  :on_membership, :identifier, :access_result_options, :image

  attr_accessor :remove_image

  delegate :environment, to: :profile

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

  scope :accessible_to, -> user, profile {
    where('access <= ?', AccessLevels.permission(user, profile))
  }

  def expired?
    (begining.present? && Time.now < begining) || (ending.present? && Time.now > ending)
  end

  def will_open?
    begining.present? && Time.now < begining
  end

  def access_levels
    AccessLevels.range_options(0, 2)
  end

  def image
    self.article
  end

  def image=(uploaded_file)
    self.article = uploaded_file
  end

  def default_img_url
    "/plugins/custom_forms/images/default-#{kind.underscore}.png"
  end

  def image_url
    image.present? ? image.full_path : default_img_url
  end

  def status
    if begining.try(:future?)
      :not_open
    elsif ending.try(:future?) && (ending < 3.days.from_now)
      :closing_soon
    elsif ending.nil? || ending.try(:future?)
      :open
    else
      :closed
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
    (result_access.blank?) ||
    (result_access == 'public') ||
    (
      result_access == 'public_after_ends' && 
      ((ending.present? && (ending < DateTime.now)) || can_view?(person))
    ) ||
    ((result_access == 'private') && can_view?(person))
  end

  private
  def can_view?(person)
    (person == profile ||
    person.in?(profile.admins) ||
    person.in?(profile.environment.admins))
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
