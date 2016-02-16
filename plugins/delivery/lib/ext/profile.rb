require_dependency 'profile'

([Profile] + Profile.descendants).each do |subclass|
subclass.class_eval do

  has_many :delivery_methods, -> { order 'id ASC' }, class_name: 'DeliveryPlugin::Method', foreign_key: :profile_id, dependent: :destroy

end
end
