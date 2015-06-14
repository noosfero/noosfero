require_dependency 'profile'

class Profile

  has_many :delivery_methods, class_name: 'DeliveryPlugin::Method', foreign_key: :profile_id, dependent: :destroy, order: 'id ASC'

end
