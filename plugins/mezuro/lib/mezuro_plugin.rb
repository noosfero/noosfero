require 'yaml'

Savon.configure do |config|
  config.log = HTTPI.log = (RAILS_ENV == 'development')
end

class MezuroPlugin < Noosfero::Plugin

  def self.plugin_name
    "Mezuro"
  end

  def self.plugin_description
    _("A metric analizer plugin.")
  end

  def control_panel_buttons
    if context.profile.is_a?(Community)
      {:title => _('Mezuro Project'), :url => {:controller =>  'cms', :action => 'new', :profile => context.profile.identifier, :type => 'MezuroPlugin::ProjectContent'}, :icon => 'mezuro' }
    else
      {:title => _('Mezuro Configuration'), :url => {:controller =>  'cms', :action => 'new', :profile => context.profile.identifier, :type => 'MezuroPlugin::ConfigurationContent'}, :icon => 'mezuro' }
    end
  end

  def control_panel_buttons
    if context.profile.is_a?(Community)
      {:title => _('Mezuro Project'), :url => {:controller =>  'cms', :action => 'new', :profile => context.profile.identifier, :type => 'MezuroPlugin::ProjectContent'} }
    else
     {:title => _('Mezuro Configuration'), :url => {:controller =>  'cms', :action => 'new', :profile => context.profile.identifier, :type => 'MezuroPlugin::ConfigurationContent'} }
    end
  end


  def stylesheet?
    true
  end

end
