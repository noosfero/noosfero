Tag = ActsAsTaggableOn::Tag
class Tag

  attr_accessible :name, :parent_id, :pending

  has_many :children, class_name: 'Tag', foreign_key: 'parent_id', dependent: :destroy

  @@original_find = self.method(:find)
  # Rename the find method to find_with_pendings that includes all tags in the search regardless if its pending or not
  def self.find_with_pendings(*args)
    @@original_find.call(*args)
  end

  # Redefine the find method to exclude the pending tags from the search not allowing to tag something with an unapproved tag
  def self.find(*args)
    self.where(pending: false).find_with_pendings(*args)
  end

  # Return all the tags that were suggested but not yet approved
  def self.find_pendings
    self.where(pending: true)
  end

  # All the tags that can be a new parent for this tag, that is all but itself and its descendents to avoid loops
  def parent_candidates
    ActsAsTaggableOn::Tag.all - descendents - [self]
  end

  # All tags that have this tag as its one of its ancestors
  def descendents
    children.to_a.sum([], &:descendents) + children
  end

end
