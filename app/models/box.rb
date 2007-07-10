class Box < ActiveRecord::Base
  has_many :blocks
  belongs_to :owner, :polymorphic => true

  #we cannot have two boxs with the same number to the same owner
  validates_uniqueness_of :number, :scope => [:owner_type, :owner_id]

  #<tt>number</tt> could not be nil and must be an integer
  validates_numericality_of :number, :only_integer => true, :message => _('%{fn} must be composed only of integers.')

  # Find all boxes except the box with the id given.
  def self.find_not_box(box_id)
    return Box.find(:all, :conditions => ['id != ?', box_id])
  end

  # Return all blocks of the current box object sorted by the position block
  def blocks_sort_by_position
    self.blocks.sort{|x,y| x.position <=> y.position}
  end

end
