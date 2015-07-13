require 'test_helper'
require_relative '../../controllers/spaminator_plugin_admin_controller'

class SpaminatorPluginAdminControllerTest < ActionController::TestCase
  def setup
    @controller = SpaminatorPluginAdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @environment = Environment.default
    @settings = Noosfero::Plugin::Settings.new(@environment, SpaminatorPlugin)
    login_as(create_admin_user(@environment))
  end

  attr_accessor :settings, :environment

  should 'deploy spaminator' do
    SpaminatorPlugin.expects(:schedule_scan).with(environment)
    get :deploy
    reload_settings
    assert settings.deployed
  end

  should 'deploy spaminator when already deployed' do
    settings.deployed = true
    settings.save!
    SpaminatorPlugin.expects(:scheduled_scan).never

    get :deploy
  end

  should 'withhold spaminator' do
    settings.deployed = true
    settings.save!

    get :withhold
    reload_settings

    assert !settings.deployed
  end

  should 'make spaminator scan' do
    Delayed::Job.expects(:enqueue)

    get :scan
    reload_settings

    assert settings.scanning
  end

  should 'not scan if already scanning' do
    settings.scanning = true
    settings.save!
    Delayed::Job.expects(:enqueue).never

    get :scan
  end

  should 'remove scheduled scan' do
    SpaminatorPlugin.schedule_scan(environment)
    reload_settings

    assert settings.scheduled_scan
    assert Delayed::Job.exists?(settings.scheduled_scan)

    @controller.stubs(:settings).returns(settings)
    @controller.send(:remove_scheduled_scan)
    reload_settings

    assert settings.scheduled_scan.nil?
    assert !Delayed::Job.exists?(settings.scheduled_scan)
  end

  private

  def reload_settings
    environment.reload
    settings = Noosfero::Plugin::Settings.new(environment, SpaminatorPlugin)
  end
end
