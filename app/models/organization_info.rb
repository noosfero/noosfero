class OrganizationInfo < ActiveRecord::Base
  belongs_to :organization
  
  validates_numericality_of :foundation_year, :only_integer => true, :allow_nil => true
end
