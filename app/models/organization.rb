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

end
