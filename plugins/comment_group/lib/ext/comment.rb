require_dependency 'comment'

class Comment

  scope :without_group, :conditions => {:group_id => nil }

  scope :in_group, proc { |group_id| {
      :conditions => ['group_id = ?', group_id]
    }
  }

  attr_accessible :group_id

end
