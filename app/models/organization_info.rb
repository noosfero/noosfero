class OrganizationInfo < ActiveRecord::Base
  belongs_to :organization
  
  validates_numericality_of :foundation_year, :only_integer => true, :allow_nil => true

  validates_format_of :contact_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |info| ! info.contact_email.nil? })
end
