class Unit < ApplicationRecord

  acts_as_list scope: -> unit { where environment_id: unit.environment_id }

  attr_accessible :name, :singular, :plural, :environment

  validates_presence_of :singular
  validates_presence_of :plural

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
