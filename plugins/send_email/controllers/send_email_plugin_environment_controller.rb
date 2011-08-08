class SendEmailPluginEnvironmentController < ApplicationController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  include SendEmailPluginBaseController
end
