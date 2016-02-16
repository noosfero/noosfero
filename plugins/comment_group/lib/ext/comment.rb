require_dependency 'comment'

class Comment

  scope :without_group, -> { where group_id: nil }

  scope :in_group, -> group_id { where 'group_id = ?', group_id }

  attr_accessible :group_id

end
