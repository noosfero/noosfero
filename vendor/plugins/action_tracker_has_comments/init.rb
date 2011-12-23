# monkey patch to add comments on action_tracker

ActionTracker::Record.module_eval do

  has_many :comments, :class_name => 'Comment', :foreign_key => 'source_id', :dependent => :destroy, :order => 'created_at asc'

end
