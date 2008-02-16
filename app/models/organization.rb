# Represents any organization of the system and has an organization_info object to hold its info
class Organization < Profile  
  has_one :organization_info

  belongs_to :region

  has_one :validation_info

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
    CreateEnterprise.pending_for(self)
  end

  def find_pending_validation(code)
    CreateEnterprise.pending_for(self, :code => code).first
  end

  def processed_validations
    CreateEnterprise.processed_for(self)
  end

  def find_processed_validation(code)
    CreateEnterprise.processed_for(self, :code => code).first
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
    # nothing ..., MainBlock is already there
    
    # "left" area
    self.boxes[1].blocks << ProfileInfoBlock.new
    self.boxes[1].blocks << RecentDocumentsBlock.new

    # "right" area
    self.boxes[2].blocks << MembersBlock.new
    self.boxes[2].blocks << TagsBlock.new
  end

end
