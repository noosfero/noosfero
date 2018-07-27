class CreateProfileAccessFriendships < ActiveRecord::Migration
  def up
    noosfero_env = ENV['RAILS_ENV']
    if noosfero_env != 'production'
      create_view :profile_access_friendships, materialized: false
    else
      create_view :profile_access_friendships, materialized: true
      ProfileAccessFriendship.refresh()
      ProfileAccessMembership.refresh()
    end
  end

  def down
    noosfero_env = ENV['RAILS_ENV']
    materialized = noosfero_env == 'production'  ? true : false
    drop_view :profile_access_friendships, materialized: materialized
  end
end

