# Represents any organization of the system
class Organization < Profile

  settings_items :closed, :type => :boolean, :default => false
  def closed?
    closed
  end

  belongs_to :region

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

  settings_items :contact_person, :contact_email, :acronym, :foundation_year, :legal_form, :economic_activity, :management_information, :validated, :cnpj

  validates_format_of :foundation_year, :with => Noosfero::Constants::INTEGER_FORMAT

  validates_format_of :contact_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |org| !org.contact_email.nil? })

  xss_terminate :only => [ :acronym, :contact_person, :contact_email, :legal_form, :economic_activity, :management_information ]

  def summary
    [ 'acronym', 'foundation_year', 'contact_person', 'contact_email', 'legal_form', 'economic_activity' ].map do |col|
      [ col.humanize, self.send(col) ]
    end
  end

  # Yes, organizations have members.
  #
  # Returns <tt>true</tt>.
  def has_members?
    true
  end

  hacked_after_create :create_default_set_of_blocks_for_organization
  def create_default_set_of_blocks_for_organization
    # "main" area
    self.boxes[0].blocks << MainBlock.new
    
    # "left" area
    self.boxes[1].blocks << ProfileInfoBlock.new
    self.boxes[1].blocks << RecentDocumentsBlock.new

    # "right" area
    self.boxes[2].blocks << MembersBlock.new
    self.boxes[2].blocks << TagsBlock.new
  end

end
