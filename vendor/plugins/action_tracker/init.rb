require "user_stamp"

UserStamp.creator_attribute = :user
UserStamp.updater_attribute = :user

class ActionController::Base
  extend UserStamp::ClassMethods
end

require "action_tracker"
