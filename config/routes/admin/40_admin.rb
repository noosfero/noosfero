Noosfero::Application.routes.draw do

  match 'admin', controller: :admin_panel, action: :index, via: :all
  match 'admin/:controller(/:action((.:format)/:id))', controller: Noosfero.pattern_for_controllers_in_directory('admin'), via: :all
  match 'admin/:controller(/:action(/:id))', controller: Noosfero.pattern_for_controllers_in_directory('admin'), via: :all

end
