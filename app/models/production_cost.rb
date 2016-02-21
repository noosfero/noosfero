class ProductionCost < ApplicationRecord

  attr_accessible :name, :owner

  belongs_to :owner, :polymorphic => true
  validates_presence_of :owner
  validates_presence_of :name
  validates_length_of :name, :maximum => 30, :allow_blank => true
  validates_uniqueness_of :name, :scope => [:owner_id, :owner_type]

end
