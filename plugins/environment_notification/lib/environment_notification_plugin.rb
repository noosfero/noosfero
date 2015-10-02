class EnvironmentNotificationPlugin < Noosfero::Plugin

  def self.plugin_name
    "Environment Notifications Plugin"
  end

  def self.plugin_description
    _("A plugin for environment notifications.")
  end

  def stylesheet?
    true
  end

  def js_files
    %w(
    public/environment_notification_plugin.js
    )
  end

  def body_beginning
    lambda do
      extend EnvironmentNotificationHelper
      render template: 'environment_notification_plugin_admin/show_notification'
    end
  end

  def admin_panel_links
    {:title => _('Notification Manager'), :url => {:controller => 'environment_notification_plugin_admin', :action => 'index'}}
  end

  def account_controller_filters
    block = proc do
      if !logged_in?
        cookies[:hide_notifications] = nil
      end
    end

    [{
      :type => "after_filter",
      :method_name => "clean_hide_notifications_cookie",
      :options => { },
      :block => block
    }]
  end
end
