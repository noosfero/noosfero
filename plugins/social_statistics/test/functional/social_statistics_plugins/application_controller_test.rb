# encoding: UTF-8
require_relative "../../../../../test/test_helper"
require_relative '../../../lib/ext/application_controller'

class SocialStatisticsPlugin::ApplicationControllerTest < ActionController::TestCase
  def setup
    @controller = ApplicationController.new
  end

  should 'render not_found if user is blank' do
    @controller.stubs(:user).returns(nil)
    @controller.expects(:social_statistics_plugin_not_found)
    @controller.social_statistics_plugin_verify_access
  end

  should 'render not_found if environment blank' do
    user = mock()
    user.stubs(:environment).returns(nil)
    @controller.stubs(:user).returns(user)
    @controller.expects(:social_statistics_plugin_not_found)
    @controller.social_statistics_plugin_verify_access
  end

  should 'render not_found if plugin is disabled' do
    user = mock()
    environment = mock()
    environment.stubs(:plugin_enabled?).with('SocialStatisticsPlugin').returns(false)
    user.stubs(:environment).returns(environment)
    @controller.stubs(:user).returns(user)
    @controller.expects(:social_statistics_plugin_not_found)
    @controller.social_statistics_plugin_verify_access
  end

  should 'render access_denied if user is not admin' do
    user = mock()
    environment = mock()
    environment.stubs(:plugin_enabled?).with('SocialStatisticsPlugin').returns(true)
    user.stubs(:environment).returns(environment)
    user.stubs(:is_admin?).returns(false)
    @controller.stubs(:user).returns(user)
    @controller.expects(:social_statistics_plugin_not_found).never
    @controller.expects(:social_statistics_plugin_access_denied)
    @controller.social_statistics_plugin_verify_access
  end

  should 'not render anything' do
    user = mock()
    environment = mock()
    environment.stubs(:plugin_enabled?).with('SocialStatisticsPlugin').returns(true)
    user.stubs(:environment).returns(environment)
    user.stubs(:is_admin?).returns(true)
    @controller.stubs(:user).returns(user)
    @controller.expects(:social_statistics_plugin_not_found).never
    @controller.expects(:social_statistics_plugin_access_denied).never
    @controller.social_statistics_plugin_verify_access
  end
end
