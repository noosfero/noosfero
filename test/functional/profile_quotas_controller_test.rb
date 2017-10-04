require_relative '../test_helper'

class ProfileQuotasControllerTest < ActionController::TestCase

  def setup
    @person = fast_create(Person, name: 'person')
    @community = fast_create(Community, name: 'community')
    @kind = fast_create(Kind, name: 'K1',
                        environment_id: Environment.default.id)

    admin = create_user.person
    Environment.default.add_admin admin
    login_as admin.identifier
  end

  should 'filter profiles by type' do
    get :index, asset: 'people'
    assert_tag tag: 'td', content: @person.name
    assert_no_tag tag: 'td', content: @community.name
  end

  should 'return all profiles when asset is invalid' do
    get :index, asset: 'invalid'
    assert_tag tag: 'td', content: @person.name
    assert_tag tag: 'td', content: @community.name
  end

  should 'filter profiles by name' do
    get :index, q: @community.name
    assert_no_tag tag: 'td', content: @person.name
    assert_tag tag: 'td', content: @community.name
  end

  should 'respond to json with the list of filtered profiles names' do
    xhr :get, :index, format: 'json'
    profiles = json_response
    assert @person.name.in? json_response
    assert @community.name.in? json_response
  end

  should 'redirect to index when editing a nonexistent class' do
    get :edit_class, type: 'invalid'
    assert_redirected_to action: :index
  end

  should 'redirect to index when editing an invalid class' do
    get :edit_class, type: 'task'
    assert_redirected_to action: :index
  end

  should 'edit quota for class' do
    post :edit_class, type: 'person', quota: { size: '100.0' }
    assert_equal 100.0, Environment.default.quota_for(Person)
    assert_redirected_to action: :index
  end

  should 'display errors when it fails to edit quota for class' do
    post :edit_class, type: 'person', quota: { size: 'not' }
    assert_template :edit_class
    assert_tag tag: 'div', attributes: { class: 'errorExplanation' }
  end

  should 'edit quota for kind' do
    Kind.any_instance.stubs(:type).returns('Person')
    post :edit_kind, id: @kind.id, quota: { size: '300.0' }
    @kind.reload
    assert_equal 300.0, @kind.upload_quota
    assert_redirected_to action: :index
  end

  should 'display errors when it failes to edit quota for kind' do
    Kind.any_instance.stubs(:type).returns('Person')
    post :edit_kind, id: @kind.id, quota: { size: 'nope' }
    assert_template :edit_kind
    assert_tag tag: 'div', attributes: { class: 'errorExplanation' }
  end

  should 'edit quota for profile' do
    post :edit_profile, id: @community.id, quota: { size: '500.0' }
    @community.reload
    assert_equal 500.0, @community.upload_quota
    assert_redirected_to action: :index
  end

  should 'display errors when it failes to edit quota for profile' do
    post :edit_profile, id: @community.id, quota: { size: 'why' }
    assert_template :edit_profile
    assert_tag tag: 'div', attributes: { class: 'errorExplanation' }
  end

  should 'reset quotas by profile class' do
    env = Environment.default
    env.metadata['quotas'] = { 'Community' => 100 }
    env.save

    @community.update_attributes(upload_quota: 500)

    delete :reset_class, type: 'Community'
    @community.reload
    assert_equal env.quota_for(Community), @community.upload_quota
  end

  should 'not reset quotas by profle class if type is invalid' do
    delete :reset_class, type: 'invalid'
    assert session[:notice].present?
  end

  should 'reset quotas by profile kind' do
    @community.update_attributes(upload_quota: 500)
    @kind.update_attributes(upload_quota: 1000)
    @kind.profiles << @community

    delete :reset_kind, id: @kind.id
    @community.reload
    assert_equal @kind.upload_quota, @community.upload_quota
  end

  should 'reset quotas by profile kind when quota is unlimited' do
    @community.update_attributes(upload_quota: 500)
    @kind.update_attributes(upload_quota: '')
    @kind.profiles << @community

    delete :reset_kind, id: @kind.id
    @community.reload
    assert @community.upload_quota.nil?
  end

  should 'silently redirect to index if kind does not exist' do
    delete :reset_kind, id: 'do not exist'
    assert_redirected_to action: :index
  end

  should 'reset quota of a single profile' do
    @community.update_attributes(upload_quota: 1000)

    delete :reset_profile, id: @community.id
    @community.reload
    assert_nil @community.upload_quota
  end

  should 'silently redirect to index if profile does not exist' do
    delete :reset_profile, id: 'do not exist'
    assert_redirected_to action: :index
  end

end
