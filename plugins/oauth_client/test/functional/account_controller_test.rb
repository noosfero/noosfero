require 'test_helper'

class AccountControllerTest < ActionController::TestCase
  def setup
    external_person = ExternalPerson.create!(identifier: 'johnlock',
                                     name: 'John Locke',
                                     source: 'anerenvironment.org',
                                     email: 'john@locke.org',
                                     created_at: Date.yesterday
                                    )
    session[:external] = external_person.id
  end

  should "not create an User when logging out" do
    assert_no_difference 'User.count' do
      get :logout
    end
  end
end
