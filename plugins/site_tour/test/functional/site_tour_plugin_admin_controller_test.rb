require 'test_helper'

class SiteTourPluginAdminControllerTest < ActionController::TestCase

  def setup
    @environment = Environment.default
    login_as(create_admin_user(@environment))
  end

  attr_reader :environment

  should 'parse csv and save actions array in plugin settings' do
    actions_csv = "en,tour_plugin,.tour-button,Click"
    post :index, :settings => {"actions_csv" => actions_csv}
    @settings = Noosfero::Plugin::Settings.new(environment.reload, SiteTourPlugin)
    assert_equal [{:language => 'en', :group_name => 'tour_plugin', :selector => '.tour-button', :description => 'Click'}], @settings.actions
  end

  should 'parse csv and save group triggers array in plugin settings' do
    group_triggers_csv = "tour_plugin,.tour-button,mouseenter"
    post :index, :settings => {"group_triggers_csv" => group_triggers_csv}
    @settings = Noosfero::Plugin::Settings.new(environment.reload, SiteTourPlugin)
    assert_equal [{:group_name => 'tour_plugin', :selector => '.tour-button', :event => 'mouseenter'}], @settings.group_triggers
  end

  should 'do not store actions_csv' do
    actions_csv = "en,tour_plugin,.tour-button,Click"
    post :index, :settings => {"actions_csv" => actions_csv}
    @settings = Noosfero::Plugin::Settings.new(environment.reload, SiteTourPlugin)
    assert_equal nil, @settings.settings[:actions_csv]
  end

  should 'do not store group_triggers_csv' do
    group_triggers_csv = "tour_plugin,.tour-button,click"
    post :index, :settings => {"group_triggers_csv" => group_triggers_csv}
    @settings = Noosfero::Plugin::Settings.new(environment.reload, SiteTourPlugin)
    assert_equal nil, @settings.settings[:group_triggers_csv]
  end

  should 'convert actions array to csv to enable user edition' do
    @settings = Noosfero::Plugin::Settings.new(environment.reload, SiteTourPlugin)
    @settings.actions = [{:language => 'en', :group_name => 'tour_plugin', :selector => '.tour-button', :description => 'Click'}]
    @settings.save!

    get :index
    assert_tag :tag => 'textarea', :attributes => {:class => 'actions-csv'}, :content => "\nen,tour_plugin,.tour-button,Click\n"
  end

  should 'convert group_triggers array to csv to enable user edition' do
    @settings = Noosfero::Plugin::Settings.new(environment.reload, SiteTourPlugin)
    @settings.group_triggers = [{:group_name => 'tour_plugin', :selector => '.tour-button', :event => 'click'}]
    @settings.save!

    get :index
    assert_tag :tag => 'textarea', :attributes => {:class => 'groups-csv'}, :content => "\ntour_plugin,.tour-button,click\n"
  end

end
