require_relative "../test_helper"
require 'kinds_controller'

class KindsControllerTest < ActionController::TestCase
  def setup
    @controller = KindsController.new
    @environment = Environment.default
    create_user_with_permission('adminuser', 'manage_environment_kinds', environment)
    login_as('adminuser')
  end

  attr_accessor :environment

  should 'list kinds' do
    pk1 = Kind.create(:environment_id => environment.id, :type => 'Person', :name => 'Captain')
    pk2 = Kind.create(:environment_id => environment.id, :type => 'Person', :name => 'Officer')

    ck1 = Kind.create(:environment_id => environment.id, :type => 'Community', :name => 'Discussion')
    ck2 = Kind.create(:environment_id => environment.id, :type => 'Community', :name => 'Decision')
    ck3 = Kind.create(:environment_id => environment.id, :type => 'Community', :name => 'Proposal')

    ek1 = Kind.create(:environment_id => environment.id, :type => 'Enterprise', :name => 'Market')
    ek2 = Kind.create(:environment_id => environment.id, :type => 'Enterprise', :name => 'Production')

    get 'index'

    assert_equivalent [pk1, pk2], assigns(:kinds)['Person']
    assert_equivalent [ck1, ck2, ck3], assigns(:kinds)['Community']
    assert_equivalent [ek1, ek2], assigns(:kinds)['Enterprise']
  end

  should 'set type on new' do
    get 'new', :kind => {:type => 'Profile'}
    assert_equal 'Profile', assigns(:kind).type
  end

  should 'create new kind' do
    type = 'Person'
    name = 'Captain'

    post 'new', :kind => {:type => type, :name => name}

    kind = environment.kinds.where(:name => name).first
    assert kind.present?
    assert_equal name, kind.name
    assert_equal type, kind.type
  end

  should 'edit kind' do
    name = 'Officer'
    type = 'Person'
    kind = Kind.create(:environment_id => environment.id, :type => 'Person', :name => 'Captain')

    post 'edit', :id => kind.id, :kind => {:type => type, :name => name}

    kind.reload
    assert_equal name, kind.name
    assert_equal type, kind.type
  end

  should 'destroy kind' do
    kind = Kind.create(:environment_id => environment.id, :type => 'Person', :name => 'Captain')
    post 'destroy', :id => kind.id
    assert_raise ActiveRecord::RecordNotFound do
      kind.reload
    end
  end
end
