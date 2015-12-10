require_relative '../device_token'
Dir[File.dirname(__FILE__) + "/observers/*"].each {|file| require file}
module PushNotificationPlugin::Observers
  include PushNotificationHelper
  constants.collect{|const_name| const_get(const_name)}.select {|const| const.class == Module}.each{|submodule| include submodule}
end
