require_dependency 'comment'

class Comment

  named_scope :without_group, :conditions => {:group_id => nil }

  named_scope :in_group, lambda { |group_id| {
      :conditions => ['group_id = ?', group_id]
    }
  }

end
