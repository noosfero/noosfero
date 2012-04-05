require "test_helper"
require File.dirname(__FILE__) + '/../controllers/mezuro_plugin_myprofile_controller'

class MezuroTest < ActiveSupport::TestCase

  should 'create a mezuro project' do
    controller = MezuroPluginMyprofileController.new
    controller.create
  end

end
