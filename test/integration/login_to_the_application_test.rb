require "#{File.dirname(__FILE__)}/../test_helper"

class LoginToTheApplicationTest < ActionController::IntegrationTest
  fixtures :users, :virtual_communities, :profiles

  def test_anonymous_user_logins_to_application
    get '/'
    assert_tag :tag => 'span', :attributes => { :id => 'login_box' }
    assert_no_tag :tag => 'span', :attributes => { :id => 'user_links'  }
    assert_no_tag :tag => 'span', :attributes => { :id => 'logout_box'  }

    get '/account/login'
    assert_response :success

    login('ze', 'test')

    assert_no_tag :tag => 'span', :attributes => { :id => 'login_box' }
    assert_tag :tag => 'span', :attributes => { :id => 'user_links'  }
    assert_tag :tag => 'span', :attributes => { :id => 'logout_box'  }
  end

  def test_logged_in_does_not_see_login_box
    login('ze', 'test')
    get '/'
    assert_no_tag :tag => 'span', :attributes => { :id => 'login_box' }
    assert_no_tag :tag => 'span', :attributes => { :id => 'register_box' }
    assert_tag :tag => 'span', :attributes => { :id => 'user_links'  }
    assert_tag :tag => 'span', :attributes => { :id => 'logout_box'  }
  end

end
