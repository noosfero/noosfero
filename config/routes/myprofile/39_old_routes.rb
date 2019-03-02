Noosfero::Application.routes.draw do

  #FIXME Old routing system
  match 'myprofile/:profile/:controller(/:action(/:id))', controller: Noosfero.pattern_for_controllers_in_directory('my_profile'), profile: /#{Noosfero.identifier_format_in_url}/i, as: :myprofile, via: :all

end
