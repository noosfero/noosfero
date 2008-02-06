class Tag < ActiveRecord::Base  
  has_many :taggings
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  class << self
    delegate :delimiter, :delimiter=, :to => TagList
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end

  def self.hierarchical=(bool)
    if bool
      acts_as_tree
    end
  end

  # All the tags that can be a new parent for this tag, that is all but itself and its descendents to avoid loops
  def parent_candidates
    Tag.find_all_by_pending(false) - descendents - [self]
  end
  
  # All tags that have this tag as its one of its ancestors
  def descendents
    children.to_a.sum([], &:descendents) + children 
  end

end
