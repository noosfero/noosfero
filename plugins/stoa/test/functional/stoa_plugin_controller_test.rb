require 'test_helper'
require_relative '../../controllers/stoa_plugin_controller'

class StoaPluginControllerTest < ActionController::TestCase

  SALT=YAML::load(File.open(StoaPlugin.root_path + 'config.yml'))['salt']

  def setup
    @controller = StoaPluginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ActiveRecord::Base.configurations['stoa'] = {:adapter => 'sqlite3', :database => ':memory:', :verbosity => 'quiet'}
    env = Environment.default
    env.enable_plugin(StoaPlugin.name)
    env.enable('skip_new_user_email_confirmation')
    env.save!
    @user = create_user_full('real_user', {:password => '123456', :password_confirmation => '123456'}, {:usp_id => 9999999})
    @user.activate
  end

  attr_accessor :user

  should 'not authenticate if method not post' do
    get :authenticate, :login => user.login, :password => '123456'

    assert_not_nil json_response['error']
    assert_match /post method/,json_response['error']
  end

  should 'not authenticate if method password is wrong' do
    post :authenticate, :login => user.login, :password => 'wrong_password'

    assert_not_nil json_response['error']
    assert_match /password/,json_response['error']
  end

  should 'authenticate if everything is right' do
    post :authenticate, :login => user.login, :password => '123456'

    assert_nil json_response['error']
    assert_equal user.login, json_response['username']
  end

  should 'authenticate with usp_id' do
    post :authenticate, :usp_id => user.person.usp_id.to_s, :password => '123456'

    assert_nil json_response['error']
    assert_equal user.login, json_response['username']
  end

  should 'return no fields if fields requested was none' do
    post :authenticate, :login => user.login, :password => '123456', :fields => 'none'

    expected_response = {'ok' => true}

    assert_nil json_response['error']
    assert_equal expected_response, json_response
  end

  should 'return only the essential fields if no fields requested' do
    post :authenticate, :login => user.login, :password => '123456'
    response = json_response.clone

    assert_nil response['error']
    assert_equal true, response.delete('ok')
    assert_equal user.login, response.delete('username')
    assert_equal user.email, response.delete('email')
    assert_equal user.person.usp_id.to_s, response.delete('nusp')
    assert response.blank?
  end

  should 'return only selected fields' do
    Person.any_instance.stubs(:f1).returns('field1')
    Person.any_instance.stubs(:f2).returns('field2')
    Person.any_instance.stubs(:f3).returns('field3')
    @controller.stubs(:selected_fields).returns(%w[f1 f2 f3])

    post :authenticate, :login => user.login, :password => '123456', :fields => 'special'
    response = json_response.clone

    assert_equal true, response.delete('ok')
    assert_equal 'field1', response.delete('f1')
    assert_equal 'field2', response.delete('f2')
    assert_equal 'field3', response.delete('f3')
    assert response.blank?
  end

  should 'not return private fields' do
    Person.any_instance.stubs(:f1).returns('field1')
    Person.any_instance.stubs(:f2).returns('field2')
    Person.any_instance.stubs(:f3).returns('field3')
    StoaPluginController::FIELDS['special'] = %w[f1 f2 f3]
    person = user.person
    person.fields_privacy = {:f1 => 'private', :f2 => 'public', :f3 => 'public'}
    person.save!

    post :authenticate, :login => user.login, :password => '123456', :fields => 'special'

    refute json_response.keys.include?('f1')
    assert json_response.keys.include?('f2')
    assert json_response.keys.include?('f3')
  end

  should 'return essential fields even if they are private' do
    person = user.person
    person.fields_privacy = {:email => 'private'}
    person.save!

    post :authenticate, :login => user.login, :password => '123456'

    assert json_response.keys.include?('email')
  end

  should 'return only essential fields when profile is private' do
    Person.any_instance.stubs(:f1).returns('field1')
    Person.any_instance.stubs(:f2).returns('field2')
    Person.any_instance.stubs(:f3).returns('field3')
    StoaPluginController::FIELDS['special'] = %w[f1 f2 f3] + StoaPluginController::FIELDS['essential']
    person = user.person
    person.public_profile = false
    person.save!

    post :authenticate, :login => user.login, :password => '123456', :fields => 'special'
    response = json_response.clone

    assert_nil response['error']
    assert_equal true, response.delete('ok')
    assert_equal user.login, response.delete('username')
    assert_equal user.email, response.delete('email')
    assert_equal user.person.usp_id.to_s, response.delete('nusp')
    assert response.blank?
  end

  should 'not crash if usp_id is invalid' do
    assert_nothing_raised do
      post :authenticate, :usp_id => 12321123, :password => '123456'
    end
    assert_not_nil json_response['error']
    assert_match /user/,json_response['error']
  end

  should 'check valid usp id' do
    usp_id = '12345678'
    StoaPlugin::UspUser.stubs(:exists?).with(usp_id).returns(true)
    get :check_usp_id, :usp_id => usp_id
    assert json_response['exists']
  end

  should 'check invalid usp id' do
    usp_id = '87654321'
    StoaPlugin::UspUser.stubs(:exists?).with(usp_id).returns(false)
    get :check_usp_id, :usp_id => usp_id
    refute json_response['exists']
  end

  should 'check existent cpf' do
    usp_id = '12345678'
    user = mock
    user.stubs(:cpf).returns('12345678')
    StoaPlugin::UspUser.stubs(:find_by_codpes).with(usp_id).returns(user)
    get :check_cpf, :usp_id => usp_id
    assert json_response['exists']
  end

  should 'check not existent cpf' do
    usp_id_with_cpf = '12345678'
    user_with_cpf = mock
    user_with_cpf.stubs(:cpf).returns('12345678')
    StoaPlugin::UspUser.stubs(:find_by_codpes).with(usp_id_with_cpf).returns(user_with_cpf)
    get :check_cpf, :usp_id => usp_id_with_cpf
    usp_id_without_cpf = '87654321'
    user_without_cpf = mock
    user_with_cpf.stubs(:cpf).returns(nil)
    StoaPlugin::UspUser.stubs(:find_by_codpes).with(usp_id_without_cpf).returns(user_without_cpf)
    get :check_cpf, :usp_id => usp_id_without_cpf
    refute json_response['exists']
  end

  private

  def json_response
    ActiveSupport::JSON.decode @response.body
  end

end

