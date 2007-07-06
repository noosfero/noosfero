class Box < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  #we cannot have two boxs with the same number to the same owner
  validates_uniqueness_of :number, :scope => :owner

  #<tt>number</tt> must be a integer
  validates_numericality_of :number, :only_integer => true, :message => _('%{fn} must be composed only of integers.')
end
