Noosfero::Application.routes.draw do
  match 'myprofile/:profile/plugin/mailing_list_organization/:action(/:id)', controller: 'mailing_list_plugin_myprofile_organization', id: /.*/, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
  match 'myprofile/:profile/plugin/mailing_list_person/:action(/:id)', controller: 'mailing_list_plugin_myprofile_person', id: /.*/, profile: /#{Noosfero.identifier_format_in_url}/i, via: :all
end
