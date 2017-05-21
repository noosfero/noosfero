Noosfero::Application.routes.draw do

  match 'myprofile/:profile', controller: :profile_editor, action: :index, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'myprofile/:profile/:controller(/:action(/:id))', controller: Noosfero.pattern_for_controllers_in_directory('my_profile'), profile: /#{Noosfero.identifier_format_in_url}/i, as: :myprofile, via: :all

end
