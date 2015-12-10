Given /^the following notifications$/ do |table|
  settings = {}
  table.hashes.each do |item|
    settings[item[:name]] = "1"
  end
  data = {:notifications => settings}
  server_settings = Noosfero::Plugin::Settings.new(Environment.default, PushNotificationPlugin, data)
  server_settings.save!
end

Given /^that the user ([^\"]*) has the following devices$/ do |user_name,table|
  user = User.find_by(:login => user_name)
  table.hashes.each do |item|
    PushNotificationPlugin::DeviceToken.create(:user => user, :token => item[:token], :device_name => item[:name])
  end
end

Given /^that the user ([^\"]*) has the following notifications$/ do |user_name,table|
  user = User.find_by(:login => user_name)
  table.hashes.each do |item|
    user.notification_settings.activate_notification item[:name]
  end
  user.save!
end

Given /^that "([^\"]*)" is the server api key$/ do |key|
  data = {:server_api_key => key}
  server_settings = Noosfero::Plugin::Settings.new(Environment.default, PushNotificationPlugin, data)
  server_settings.save!
end
