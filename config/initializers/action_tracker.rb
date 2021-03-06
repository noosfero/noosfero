require "action_tracker_config"

# ActionTracker plugin stuff

ActionTrackerConfig.verbs = {

  create_article: {
  },

  new_friendship: {
    type: :groupable
  },

  new_follower: {
    type: :groupable
  },

  join_community: {
    type: :groupable
  },

  add_member_in_community: {
  },

  upload_image: {
    type: :groupable
  },

  leave_scrap: {
  },

  leave_scrap_to_self: {
  },

  reply_scrap_on_self: {
  },

  favorite_enterprise: {
  },

}

ActionTrackerConfig.current_user = proc do
  User.current.person rescue nil
end

ActionTrackerConfig.timeout = 24.hours
