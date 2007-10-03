class Task < ActiveRecord::Base
  belongs_to :requestor, :class_name => 'Profile', :foreign_key => :requestor_id
  belongs_to :target, :class_name => 'Profile', :foreign_key => :target_id
end
