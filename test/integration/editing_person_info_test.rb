require "#{File.dirname(__FILE__)}/../test_helper"

class EditingPersonInfoTest < ActionController::IntegrationTest

  fixtures :users, :profiles, :comatose_pages, :domains, :environments, :person_infos

  should 'allow to edit person info' do

    profile = Profile.find_by_identifier('ze')

    login('ze', 'test')

    get '/myprofile/ze'
    assert_response :success

    assert_tag :tag => 'td', :content => profile.person_info.name
    assert_tag :tag => 'td', :content => profile.person_info.address
    assert_tag :tag => 'td', :content => profile.person_info.contact_information

    get '/myprofile/ze/profile_editor/edit'
    assert_response :success

    post '/myprofile/ze/profile_editor/edit', :info => { :address => 'a new address', :contact_information => 'a new contact information' }
    assert_response :redirect

  end
end
