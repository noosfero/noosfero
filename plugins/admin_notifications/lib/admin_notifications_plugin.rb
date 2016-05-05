class AdminNotificationsPlugin < Noosfero::Plugin

  def self.plugin_name
    "Notifications Plugin"
  end

  def self.plugin_description
    _("A plugin for notifications.")
  end

  def stylesheet?
    true
  end

  def js_files
    %w(
    admin_notifications_plugin.js
    )
  end

  def body_beginning
    lambda do
      extend AdminNotificationsPlugin::NotificationHelper
      render template: 'shared/show_notification'
    end
  end

  def admin_panel_links
    {:title => _('Notification Manager'), :url => {:controller => 'admin_notifications_plugin_admin', :action => 'index'}}
  end

  def control_panel_buttons
    if context.profile.organization?
      {
        :title => _('Manage Notifications'),
        :icon => 'important',
        :url => {
          :controller => 'admin_notifications_plugin_myprofile',
          :action => 'index'
        }
      }
    end
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
