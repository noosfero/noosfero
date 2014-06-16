class Unit < ActiveRecord::Base

  attr_accessible :name, :singular, :plural, :environment

  validates_presence_of :singular
  validates_presence_of :plural

  belongs_to :environment
  validates_presence_of :environment_id
  acts_as_list :scope => :environment

  def name
    self.singular
  end
  def name=(value)
    self.singular = value
  end

end
