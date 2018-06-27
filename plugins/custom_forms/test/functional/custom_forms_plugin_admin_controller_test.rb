require 'test_helper'
require 'zip'

class CustomFormsPluginAdminControllerTest < ActionController::TestCase
  def setup
    admin = create_user.person
    Environment.default.add_admin admin
    login_as admin.identifier
  end

  should 'list only profiles that have forms' do
    profile1 = fast_create(Community)
    profile2 = fast_create(Community)
    profile3 = fast_create(Community)

    profile1.forms.create(name: 'Form 1', kind: 'poll')
    profile1.forms.create(name: 'Form 2', kind: 'poll')
    profile3.forms.create(name: 'Form 3', kind: 'survey')

    get :index
    assert_equivalent [profile1, profile3], assigns(:profiles)
  end

  should 'display an error message if there are no selected profiles' do
    post :download_files, profile_ids: []
    assert_redirected_to action: :index
    assert session[:notice].present?
  end

  should 'display an error message if there is nothing to be downloaded' do
    profile = fast_create(Community)
    post :download_files, profile_ids: [profile.id]
    assert_redirected_to action: :index
    assert session[:notice].present?
  end

  should 'return a zip with one file for every form' do
    profile1 = fast_create(Community)
    profile2 = fast_create(Community)
    profile3 = fast_create(Community)

    profile1.forms.create(name: 'Form 1', kind: 'poll')
    profile1.forms.create(name: 'Form 2', kind: 'poll')
    profile3.forms.create(name: 'Form 3', kind: 'survey')

    post :download_files, profile_ids: [profile1, profile2, profile3].map(&:id)
    num_of_files = 0
    Zip::InputStream.open(StringIO.new(response.body)) do |stream|
      while stream.get_next_entry
        num_of_files += 1
      end
    end

    assert_equal 3, num_of_files
  end

  should 'include the requested profile fields in the downloaded files' do
    profile = fast_create(Community)
    profile.forms.create(name: 'Form', kind: 'poll')
    post :download_files, profile_ids: [profile].map(&:id),
                          fields: %w(name city cell_phone)

    Zip::InputStream.open(StringIO.new(response.body)) do |stream|
      while stream.get_next_entry
        content = stream.read
        assert_match /Name,City,Cell_phone/, content
      end
    end
  end
end
