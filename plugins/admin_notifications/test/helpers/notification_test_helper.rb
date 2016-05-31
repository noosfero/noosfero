module NotificationTestHelper
  def create_notification target, display_only_in_homepage=false, message="any_message", active=true
    AdminNotificationsPlugin::WarningNotification.create!(
      :target => target,
      :message => message,
      :active => active,
      :display_only_in_homepage => display_only_in_homepage
    )
  end
end
