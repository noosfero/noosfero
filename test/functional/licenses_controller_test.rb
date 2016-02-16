require_relative "../test_helper"
require 'licenses_controller'

class LicensesControllerTest < ActionController::TestCase

  def setup
    @controller = LicensesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @environment = Environment.default
    login_as(create_admin_user(@environment))
  end

  attr_accessor :environment

  should 'list environment licenses' do
    l1 = License.create!(:name => 'GPLv3', :environment => environment)
    l2 = License.create!(:name => 'AGPL', :environment => environment)

    get :index

    assert_includes assigns(:licenses), l1
    assert_includes assigns(:licenses), l2
  end

  should 'not list licenses from other environments' do
    other_env = fast_create(Environment)
    l1 = License.create!(:name => 'GPLv3', :environment => environment)
    l2 = License.create!(:name => 'AGPL', :environment => other_env)
    @controller.stubs(:environment).returns(environment)

    get :index

    assert_includes assigns(:licenses), l1
    assert_not_includes assigns(:licenses), l2
  end

  should 'create a new license' do
    assert_difference 'License.count', 1 do
      post :create, :license => {:name => 'GPLv3'}
    end
  end

  should 'edit a license' do
    license = License.create!(:name => 'GPLv2', :environment => environment)
    post :edit, :license_id => license.id, :license => {:name => 'GPLv3'}
    assert_equal 'GPLv3', License.last.name
  end

  should 'remove a license' do
    license = License.create!(:name => 'GPLv3', :environment => environment)
    post :remove, :license_id => license.id
    assert_raise(ActiveRecord::RecordNotFound) {License.find(license.id)}
  end

  should 'remove a license only with post method' do
    license = License.create!(:name => 'GPLv3', :environment => environment)
    get :remove, :license_id => license.id
    assert_nothing_raised ActiveRecord::RecordNotFound do
      License.find(license.id)
    end
    assert_redirected_to :action => 'index'
  end

end
