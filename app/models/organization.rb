# Represents any organization of the system and has an organization_info object to hold its info
class Organization < Profile

  has_one :organization_info

  belongs_to :region

  has_one :validation_info

  has_many :validations, :class_name => 'CreateEnterprise', :foreign_key => :target_id

  after_create do |org|
      OrganizationInfo.create!(:organization_id => org.id)
  end

  def contact_email
    self.organization_info ? self.organization_info.contact_email : nil
  end

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

  def info
    organization_info
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
