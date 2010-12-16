class MezuroPlugin < Noosfero::Plugin

  def self.plugin_name
    "Mezuro"
  end

  def self.plugin_description
    _("A metric analizer plugin.")
  end

  def control_panel_buttons
    if context.profile.community?
      { :title => 'Mezuro projects', :icon => 'mezuro', :url => {:controller => 'mezuro_plugin_myprofile', :action => 'index'} }
    end
  end

  def profile_tabs
    if context.profile.community? && !MezuroPlugin::Project.by_profile(context.profile).blank?
      MezuroPlugin::Project.by_profile(context.profile).with_tab.map do |project|
       { :title => 'Mezuro ' + project.name,
         :id => 'mezuro-project-'+project.identifier,
         :content => expanded_template(__FILE__,"views/show.html.erb",{:current_project => project}) }
      end
    end
  end

end
