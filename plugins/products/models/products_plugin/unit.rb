class ProductsPlugin::Unit < ApplicationRecord

  self.table_name = :units

  acts_as_list scope: :environment

  attr_accessible :name, :singular, :plural, :environment

  belongs_to :environment, optional: true

  validates_presence_of :environment_id
  validates_presence_of :singular
  validates_presence_of :plural

  def name
    self.singular
  end
  def name=(value)
    self.singular = value
  end

end
