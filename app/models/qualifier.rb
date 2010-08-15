class Qualifier < ActiveRecord::Base

  belongs_to :environment

  has_many :qualifier_certifiers
  has_many :certifiers, :through => :qualifier_certifiers

  validates_presence_of :environment_id
  validates_presence_of :name

end
