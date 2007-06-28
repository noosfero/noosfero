class Profile < ActiveRecord::Base
  validates_presence_of :identifier
  validates_format_of :identifier, :with => /^[a-z][a-z0-9_]+[a-z0-9]$/
end
