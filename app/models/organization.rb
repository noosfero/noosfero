# Represents any organization of the system
class Organization < Profile

  settings_items :closed, :type => :boolean, :default => false
  def closed?
    closed
  end

  settings_items :moderated_articles, :type => :boolean, :default => false
  def moderated_articles?
    moderated_articles
  end

  has_one :validation_info

  has_many :validations, :class_name => 'CreateEnterprise', :foreign_key => :target_id

  def validation_methodology
    self.validation_info ? self.validation_info.validation_methodology : nil
  end

  def validation_restrictions
    self.validation_info ? self.validation_info.restrictions : nil
  end

  def pending_validations
    validations.pending
  end

  def find_pending_validation(code)
    validations.pending.find { |pending| pending.code == code }
  end

  def processed_validations
    validations.finished
  end

  def find_processed_validation(code)
    validations.finished.find { |pending| pending.code == code }
  end

  def is_validation_entity?
    !self.validation_info.nil?
  end

  FIELDS = %w[
    nickname
    contact_person
    contact_phone
    contact_email
    legal_form
    economic_activity
    management_information
    address
  ]

  def self.fields
    FIELDS
  end

  def required_fields
    []
  end

  def active_fields
    []
  end

  N_('Contact person'); N_('Contact email'); N_('Acronym'); N_('Foundation year'); N_('Legal form'); N_('Economic activity'); N_('Management information'); N_('Validated')
  settings_items :contact_person, :contact_email, :acronym, :foundation_year, :legal_form, :economic_activity, :management_information, :validated, :cnpj

  validates_format_of :foundation_year, :with => Noosfero::Constants::INTEGER_FORMAT

  validates_format_of :contact_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |org| !org.contact_email.blank? })

  xss_terminate :only => [ :acronym, :contact_person, :contact_email, :legal_form, :economic_activity, :management_information ]

  # Yes, organizations have members.
  #
  # Returns <tt>true</tt>.
  def has_members?
    true
  end

  def default_set_of_blocks
    [
      [MainBlock],
      [ProfileInfoBlock, RecentDocumentsBlock],
      [MembersBlock, TagsBlock]
    ]
  end

  def notification_emails
    [contact_email].compact + admins.map(&:email)
  end

end
