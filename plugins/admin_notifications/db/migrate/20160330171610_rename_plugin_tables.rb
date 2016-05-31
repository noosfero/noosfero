class RenamePluginTables < ActiveRecord::Migration
  def up
    remove_index :environment_notifications_users, name: :index_Zaem6uuw
    remove_index :environment_notifications_users, name: :index_ap3nohR9

    rename_column :environment_notifications_users, :environment_notification_id, :notification_id

    rename_table :environment_notifications, :admin_notifications_plugin_notifications
    rename_table :environment_notifications_users, :admin_notifications_plugin_notifications_users

    add_index :admin_notifications_plugin_notifications_users, [:notification_id], :name => :index_notifications_users_notification_id
    add_index :admin_notifications_plugin_notifications_users, [:user_id], :name => :index_notifications_users_user_id

    Environment.all.each do |e|
      if e.enabled_plugins.include?('EnvironmentNotificationPlugin')
        e.enabled_plugins -= ['EnvironmentNotificationPlugin']
        e.enabled_plugins += ['AdminNotificationsPlugin']
        e.save!
      end
    end
  end

  def down
    remove_index :admin_notifications_plugin_notifications_users, :name => :index_notifications_users_notification_id
    remove_index :admin_notifications_plugin_notifications_users, :name => :index_notifications_users_user_id

    rename_table :admin_notifications_plugin_notifications, :environment_notifications
    rename_table :admin_notifications_plugin_notifications_users, :environment_notifications_users

    rename_column :environment_notifications_users, :notification_id, :environment_notification_id

    add_index :environment_notifications_users, [:environment_notification_id], name: :index_Zaem6uuw
    add_index :environment_notifications_users, [:user_id], name: :index_ap3nohR9
  end

  Environment.all.each do |e|
    if e.enabled_plugins.include?('AdminNotificationsPlugin')
      e.enabled_plugins -= ['AdminNotificationsPlugin']
      e.enabled_plugins += ['EnvironmentNotificationPlugin']
      e.save!
    end
  end
end
