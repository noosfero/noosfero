require 'active_record/session_store'

class ActiveRecord::SessionStore::Session

  has_many :orders, primary_key: :session_id, foreign_key: :session_id, class_name: 'OrdersPlugin::Order'

end
