require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../../../app/controllers/public/invite_controller'

# Re-raise errors caught by the controller.
class ContentViewerController; def rescue_action(e) raise e end; end

class ContentViewerControllerTest < ActionController::TestCase

  def setup
    @controller = ContentViewerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testinguser').person
    @environment = @profile.environment
    @environment.enabled_plugins = ['SocialSharePrivacyPlugin']
    @environment.save!
  end

  should 'add social content on content view page' do
    page = @profile.articles.build(:name => 'test')
    page.save!

    get :view_page, :profile => @profile.identifier, :page => ['test']

    assert_tag :tag => 'script', :attributes => {:src => /\/javascripts\/plugins\/social_share_privacy\/socialshareprivacy\/javascripts\/socialshareprivacy\.js\??\d*/}
    assert_tag :tag => 'div', :attributes => {:class => "social-buttons"}
  end

  should 'add social share privacy modules acording to networks settings' do
    page = @profile.articles.build(:name => 'test')
    page.save!
    Noosfero::Plugin::Settings.new(@environment, SocialSharePrivacyPlugin, :networks => ['twitter', 'gplus']).save!

    get :view_page, :profile => @profile.identifier, :page => ['test']

    assert_tag :tag => 'script', :attributes => {:src => /\/javascripts\/plugins\/social_share_privacy\/socialshareprivacy\/javascripts\/modules\/twitter\.js\??\d*/}
    assert_tag :tag => 'script', :attributes => {:src => /\/javascripts\/plugins\/social_share_privacy\/socialshareprivacy\/javascripts\/modules\/gplus\.js\??\d*/}
  end

  should 'add javascript with string translations if not english' do
    page = @profile.articles.build(:name => 'test')
    page.save!
    FastGettext.stubs(:locale).returns('pt')

    get :view_page, :profile => @profile.identifier, :page => ['test']

    assert_tag :tag => 'script', :attributes => {:src => /\/javascripts\/plugins\/social_share_privacy\/socialshareprivacy\/javascripts\/locale\/jquery\.socialshareprivacy\.min\.pt\.js\??\d*/}

    FastGettext.stubs(:locale).returns('en')

    get :view_page, :profile => @profile.identifier, :page => ['test']

    assert_no_tag :tag => 'script', :attributes => {:src => /\/javascripts\/plugins\/social_share_privacy\/socialshareprivacy\/javascripts\/locale\/jquery\.socialshareprivacy\.min\.en\.js\??\d*/}
  end
end
