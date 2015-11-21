require_dependency 'session'

class Session

  has_many :orders, primary_key: :session_id, foreign_key: :session_id, class_name: 'OrdersPlugin::Order'

end
