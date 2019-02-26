
class ActionDispatch::IntegrationTest

  extend Test::Should

  def assert_can_login
    assert_tag :tag => 'a', :attributes => { :id => 'link_login' }
  end

  def assert_can_signup
    assert_tag :tag => 'a', :attributes => { :href => '/account/signup'}
  end

  def login(username, password)
    ActionDispatch::Integration::Session.any_instance.stubs(:https?).returns(true)

    post '/account/login', params: { user: { login: username, password: password }}
    follow_redirect!
    assert_response :success
    assert_not_equal '/account/login', path
  end

end
