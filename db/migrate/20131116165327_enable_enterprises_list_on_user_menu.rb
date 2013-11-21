class EnableEnterprisesListOnUserMenu < ActiveRecord::Migration
  def self.up
    # The enterprises were always listed on user menu.
    # As now it is configured by admin, the running environments should not need to enable it
    select_all("select id from environments").each do |environment|
      env = Environment.find(environment['id'])
      env.enable(:display_my_enterprises_on_user_menu)
    end
  end

  def self.down
    #nothing to be done
  end
end
