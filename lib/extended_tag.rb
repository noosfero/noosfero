class Tag
  @@original_find = self.method(:find)
  def self.original_find(*args)
      @@original_find.call(*args)
  end

  def self.find(*args)
    self.with_scope(:find => { :conditions => ['pending = ?', false] }) do
       return self.original_find(*args)
    end
  end

  def self.find_pendings
    self.original_find(:all, :conditions => ['pending = ?', true])
  end

  def descendents
    children.to_a.sum([], &:descendents) + children 
  end

  def aproved?
    not pending?
  end

end
