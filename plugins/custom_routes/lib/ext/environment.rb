require_dependency 'environment'

class Environment

  has_many :custom_routes, class_name: 'CustomRoutesPlugin::Route'

end
