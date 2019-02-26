class Local < ActiveRecord::Base
  belongs_to :localizable, polymorphic:  true, optional: true
  validates_presence_of :latitude, :longitude
end