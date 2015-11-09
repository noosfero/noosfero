require 'test_helper'

class SiteTourPluginTest < ActionView::TestCase

  def setup
    @plugin = SiteTourPlugin.new
  end

  attr_accessor :plugin

  should 'include site tour plugin actions in user data for logged in users' do
    expects(:logged_in?).returns(true)
    person = create_user('testuser').person
    person.site_tour_plugin_actions = ['login', 'navigation']
    expects(:user).returns(person)

    assert_equal({:site_tour_plugin_actions => ['login', 'navigation']}, instance_eval(&plugin.user_data_extras))
  end

  should 'return empty hash when user is not logged in' do
    expects(:logged_in?).returns(false)
    assert_equal({}, instance_eval(&plugin.user_data_extras))
  end

  should 'include javascript related to tour instructions if file exists' do
    file = '/plugins/site_tour/tour/pt/tour.js'
    expects(:language).returns('pt')
    File.expects(:exists?).with(Rails.root.join("public#{file}").to_s).returns(true)
    expects(:environment).returns(Environment.default)
    assert_tag_in_string instance_exec(&plugin.body_ending), :tag => 'script'
  end

  should 'not include javascript file that not exists' do
    file = '/plugins/site_tour/tour/pt/tour.js'
    expects(:language).returns('pt')
    File.expects(:exists?).with(Rails.root.join("public#{file}").to_s).returns(false)
    expects(:environment).returns(Environment.default)
    assert_no_tag_in_string instance_exec(&plugin.body_ending), :tag => "script"
  end

  should 'render javascript tag with tooltip actions and group triggers' do
    expects(:language).returns('en').at_least_once

    settings = Noosfero::Plugin::Settings.new(Environment.default, SiteTourPlugin)
    settings.actions = [{:language => 'en', :group_name => 'test', :selector => 'body', :description => 'Test'}]
    settings.group_triggers = [{:group_name => 'test', :selector => 'body', :event => 'click'}]
    settings.save!

    expects(:environment).returns(Environment.default)
    body_ending = instance_exec(&plugin.body_ending)
    assert_match /siteTourPlugin\.add\('test', 'body', 'Test', 1\);/, body_ending
    assert_match /siteTourPlugin\.addGroupTrigger\('test', 'body', 'click'\);/, body_ending
  end

  should 'start each tooltip group with the correct step order' do
    expects(:language).returns('en').at_least_once

    settings = Noosfero::Plugin::Settings.new(Environment.default, SiteTourPlugin)
    settings.actions = [
        {:language => 'en', :group_name => 'test_a', :selector => 'body', :description => 'Test A1'},
        {:language => 'en', :group_name => 'test_a', :selector => 'body', :description => 'Test A2'},
        {:language => 'en', :group_name => 'test_b', :selector => 'body', :description => 'Test B1'},
    ]
    settings.save!

    expects(:environment).returns(Environment.default)
    body_ending = instance_exec(&plugin.body_ending)
    assert_match /siteTourPlugin\.add\('test_a', 'body', 'Test A1', 1\);/, body_ending
    assert_match /siteTourPlugin\.add\('test_a', 'body', 'Test A2', 2\);/, body_ending
    assert_match /siteTourPlugin\.add\('test_b', 'body', 'Test B1', 3\);/, body_ending
  end

end
