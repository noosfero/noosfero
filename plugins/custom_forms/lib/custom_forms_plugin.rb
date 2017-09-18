class CustomFormsPlugin < Noosfero::Plugin

  def self.plugin_name
    _('Query')
  end

  def self.plugin_description
    _("Enables the creation of custom queries like surveys or polls.")
  end

  def stylesheet?
    true
  end

  def control_panel_buttons
    {title: _('Manage Queries'), icon: 'custom-forms', url: {profile: profile.identifier, controller: 'custom_forms_plugin_myprofile'}}
  end

  def self.extra_blocks
    {
      CustomFormsPlugin::SurveyBlock => { type: [Community] },
      CustomFormsPlugin::PollsBlock => { type: [Community] }
    }
  end

  def self.load_custom_routes
    Noosfero::Application.routes.draw do
      match "/profile/:profile/query/:id" => 'custom_forms_plugin_profile#show',
        via: [:get, :post]
      get "/profile/:profile/query/:id/results" => 'custom_forms_plugin_profile#review'
    end
  end
end
