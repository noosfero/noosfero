class ValidationInfo < ActiveRecord::Base

  attr_accessible :validation_methodology, :restrictions, :organization

  validates_presence_of :validation_methodology

  belongs_to :organization

  xss_terminate :only => [ :validation_methodology, :restrictions ], :on => 'validation'
end
