# monkey patch to add comments on action_tracker

ActionTracker::Record.module_eval do

  has_many :comments, :class_name => 'Comment', :foreign_key => 'source_id', :dependent => :destroy, :finder_sql => 'SELECT * FROM comments WHERE #{conditions_for_comments} ORDER BY created_at ASC', :counter_sql => 'SELECT * FROM comments WHERE #{conditions_for_comments}'

  def conditions_for_comments
    type, id = (self.target_type == 'Article' ? ['Article', self.target_id] : [self.class.to_s, self.id])
    "source_type = '#{type}' AND source_id = '#{id}'"
  end

end
