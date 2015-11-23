
class VolunteersPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('volunteers_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('volunteers_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    ['volunteers.js'].map{ |j| "javascripts/#{j}" }
  end

end
