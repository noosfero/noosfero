require 'test_helper'

class NewsletterPluginControllerTest < ActionController::TestCase

  def setup
    @controller = NewsletterPluginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    environment = fast_create(Environment)
    environment.enable_plugin(NewsletterPlugin)
    @controller.stubs(:environment).returns(environment)
  end

  should 'require login to confirm unsubscription' do
    post :confirm_unsubscription
    assert_response 302
  end

  should 'open unsubscription page for anonymous' do
    get :unsubscribe
    assert_response :success
  end

  should 'add user email from unsubscribers list' do
    NewsletterPlugin::Newsletter.create!(
      :environment => @controller.environment,
      :person => fast_create(Person)
    )
    maria = create_user("maria").person
    login_as("maria")
    post :confirm_unsubscription
    assert_response :redirect
    assert_redirected_to :controller => 'home'
    assert_includes assigns(:newsletter).unsubscribers, maria.email
  end

end
