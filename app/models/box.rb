class Box < ActiveRecord::Base
  has_many :blocks
  belongs_to :owner, :polymorphic => true

  #we cannot have two boxs with the same number to the same owner
  validates_uniqueness_of :number, :scope => [:owner_type, :owner_id]

  #<tt>number</tt> could not be nil and must be an integer
  validates_numericality_of :number, :only_integer => true, :message => _('%{fn} must be composed only of integers.')

  def self.find_not_box(box_id)
    return Box.find(:all, :conditions => ['id != ?', box_id])
  end
end
