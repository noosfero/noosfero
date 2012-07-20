class QualifierCertifier < ActiveRecord::Base
  belongs_to :qualifier
  belongs_to :certifier

  validates_presence_of :qualifier
end
