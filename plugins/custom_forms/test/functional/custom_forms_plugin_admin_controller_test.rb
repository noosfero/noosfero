require 'test_helper'

class CustomFormsPluginAdminControllerTest < ActionController::TestCase
  should 'list only profiles that have forms' do
    profile1 = fast_create(Profile)
    profile2 = fast_create(Profile)
    profile3 = fast_create(Profile)

    profile1.forms.create(name: 'Form 1', kind: 'poll')
    profile1.forms.create(name: 'Form 2', kind: 'poll')
    profile3.forms.create(name: 'Form 3', kind: 'survey')

    get :index
    assert_equivalent [profile1, profile3], assigns(:profiles)
  end
end
