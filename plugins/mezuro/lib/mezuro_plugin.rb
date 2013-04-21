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

  def content_types
    if context.profile.is_a?(Community)
      MezuroPlugin::ProjectContent
    else
      [MezuroPlugin::ConfigurationContent,
      MezuroPlugin::ReadingGroupContent]
    end
  end

  def control_panel_buttons
    if context.profile.is_a?(Community)
      {:title => _('Mezuro project'), :url => {:controller =>  'cms', :action => 'new', :profile => context.profile.identifier, :type => 'MezuroPlugin::ProjectContent'}, :icon => 'mezuro' }
    else
      [{:title => _('Mezuro configuration'), :url => {:controller =>  'cms', :action => 'new', :profile => context.profile.identifier, :type => 'MezuroPlugin::ConfigurationContent'}, :icon => 'mezuro' },
      {:title => _('Mezuro reading group'), :url => {:controller =>  'cms', :action => 'new', :profile => context.profile.identifier, :type => 'MezuroPlugin::ReadingGroupContent'}, :icon => 'mezuro' }]
    end
  end

  def stylesheet?
    true
  end

end
