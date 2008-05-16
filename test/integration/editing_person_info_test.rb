require "#{File.dirname(__FILE__)}/../test_helper"

class EditingPersonInfoTest < ActionController::IntegrationTest

  fixtures :users, :profiles, :domains, :environments

  should 'allow to edit person info' do

    profile = Profile.find_by_identifier('ze')

    login('ze', 'test')

    get '/myprofile/ze'
    assert_response :success

    assert_tag :tag => 'a', :content => 'Edit Profile'

    get '/myprofile/ze/profile_editor/edit'
    assert_response :success

    post '/myprofile/ze/profile_editor/edit', :profile_data => { :address => 'a new address', :contact_information => 'a new contact information' }
    assert_response :redirect

  end
end
