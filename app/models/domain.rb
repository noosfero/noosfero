class Domain < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true

  validates_format_of :name, :with => /^(\w+\.)+\w+$/

end
