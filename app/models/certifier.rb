class Certifier < ActiveRecord::Base

  belongs_to :environment

  has_many :qualifier_certifiers, :dependent => :destroy
  has_many :qualifiers, :through => :qualifier_certifiers

  has_many :product_qualifiers, :dependent => :destroy
  has_many :products, :through => :product_qualifiers, :source => :product

  validates_presence_of :environment_id
  validates_presence_of :name

  def link
    self[:link] || ''
  end

  def <=>(b)
    self.name.downcase.transliterate <=> b.name.downcase.transliterate
  end

end
