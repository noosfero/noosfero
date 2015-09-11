class Qualifier < ActiveRecord::Base

  attr_accessible :name, :environment

  SEARCHABLE_FIELDS = {
    :name => {:label => _('Name'), :weight => 1},
  }

  belongs_to :environment

  has_many :qualifier_certifiers, :dependent => :destroy
  has_many :certifiers, :through => :qualifier_certifiers

  def used_certs
    Certifier.joins('INNER JOIN product_qualifiers' +
                    ' ON certifiers.id = product_qualifiers.certifier_id')
             .where(product_qualifiers: {qualifier_id: self.id})
  end

  has_many :product_qualifiers, :dependent => :destroy
  has_many :products, :through => :product_qualifiers, :source => :product

  validates_presence_of :environment_id
  validates_presence_of :name

  def <=>(b)
    self.name.downcase.transliterate <=> b.name.downcase.transliterate
  end

end
