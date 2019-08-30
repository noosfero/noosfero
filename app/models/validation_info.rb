class ValidationInfo < ApplicationRecord
  attr_accessible :validation_methodology, :restrictions, :organization

  belongs_to :organization, optional: true

  validates_presence_of :organization
  validates_presence_of :validation_methodology

  xss_terminate only: [:validation_methodology, :restrictions], on: :validation
end
