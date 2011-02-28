class Qualifier < ActiveRecord::Base

  belongs_to :environment

  has_many :qualifier_certifiers
  has_many :certifiers, :through => :qualifier_certifiers

  validates_presence_of :environment_id
  validates_presence_of :name

  has_many :product_qualifiers, :dependent => :destroy

  def <=>(b)
    self.name.downcase.transliterate <=> b.name.downcase.transliterate
  end

end
