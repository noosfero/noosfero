class ProductsPlugin::Unit < ApplicationRecord

  self.table_name = :units

  acts_as_list scope: -> unit { where environment_id: unit.environment_id }

  attr_accessible :name, :singular, :plural, :environment

  belongs_to :environment

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
