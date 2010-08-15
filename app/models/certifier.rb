class Certifier < ActiveRecord::Base

  belongs_to :environment

  has_many :qualifier_certifiers
  has_many :qualifiers, :through => :qualifier_certifiers

  validates_presence_of :environment_id
  validates_presence_of :name

  def link
    self[:link] || ''
  end
end
