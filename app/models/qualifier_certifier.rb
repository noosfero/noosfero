class QualifierCertifier < ActiveRecord::Base
  belongs_to :qualifier
  belongs_to :certifier
end
