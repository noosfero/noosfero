class ProfileAccessFriendship < ActiveRecord::Base
  def readonly
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name,
                                              concurrently: false,
                                              cascade: false)
  end
end
