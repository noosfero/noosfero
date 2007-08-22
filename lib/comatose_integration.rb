require 'comatose'

class Comatose::Page
  def self.icon
    'text-x-generic'
  end
end

Comatose.configure do |config|
  config.admin_get_root_page do 
    Comatose::Page.find_by_path(request.parameters[:profile])
  end
  config.admin_authorization do |config|
    Profile.exists?(:identifier => request.parameters[:profile])
    # FIXME: also check permissions
  end
  config.admin_includes << :authenticated_system
  config.admin_helpers << :application_helper
  config.admin_helpers << :document_helper
end
Comatose::AdminController.design :holder => 'virtual_community'
Comatose::AdminController.before_filter do |controller|
  # TODO: copy/paste; extract this into a method (see
  # app/controllers/application.rb)
  domain = Domain.find_by_name(controller.request.host)
  if domain.nil?
    virtual_community = VirtualCommunity.default
  else
    virtual_community = domain.virtual_community
    profile = domain.profile
  end
  controller.instance_variable_set('@virtual_community', virtual_community)
end
