class SiteTourPlugin < Noosfero::Plugin

  def self.plugin_name
    'SiteTourPlugin'
  end

  def self.plugin_description
    _("A site tour to show users how to use the application.")
  end

  def stylesheet?
    true
  end

  def js_files
    ['intro.min.js', 'main.js']
  end

  def user_data_extras
    proc do
      logged_in? ? {:site_tour_plugin_actions => user.site_tour_plugin_actions}:{}
    end
  end

  def body_ending
    proc do
      tour_file = "/plugins/site_tour/tour/#{language}/tour.js"
      js_file = File.exists?(Rails.root.join("public#{tour_file}").to_s) ? tour_file : ""
      settings = Noosfero::Plugin::Settings.new(environment, SiteTourPlugin)
      actions = (settings.actions||[]).select {|action| action[:language] == language}

      render(:file => 'tour_actions', :locals => { :actions => actions, :group_triggers => settings.group_triggers, :js_file => js_file})
    end
  end

  def self.extra_blocks
    { SiteTourPlugin::TourBlock => {} }
  end

  def self.actions_csv_default_setting
    'en,tour_plugin,.site-tour-plugin_tour-block .tour-button,"Click to start tour!"'
  end

end
