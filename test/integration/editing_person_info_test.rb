require_relative "../test_helper"

class EditingPersonInfoTest < ActionDispatch::IntegrationTest

  fixtures :users, :profiles, :domains, :environments

  should 'allow to edit person info' do

    profile = create_user('user_ze', :password => 'test', :password_confirmation => 'test').person

    profile.user.activate

    login(profile.identifier, 'test')

    get "/myprofile/#{profile.identifier}"
    assert_response :success

    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/profile_editor/edit" }

    get "/myprofile/#{profile.identifier}/profile_editor/edit"
    assert_response :success

    post "/myprofile/#{profile.identifier}/profile_editor/edit", :profile_data => { :address => 'a new address', :contact_information => 'a new contact information' }
    assert_response :redirect

  end
end
