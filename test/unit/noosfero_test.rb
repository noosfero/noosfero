require_relative "../test_helper"
require_dependency 'noosfero'

class NoosferoTest < ActiveSupport::TestCase

  def test_should_list_controllers_in_directory
    Dir.expects(:glob).with(Rails.root.join('app', 'controllers', 'lala', '*_controller.rb')).returns(["app/controllers/lala/system_admin_controller.rb", "app/controllers/lala/environment_admin_controller.rb", "app/controllers/lala/public_controller.rb", "app/controllers/lala/profile_admin_controller.rb"]).once
    assert_equal ["system_admin", "environment_admin", "public", "profile_admin"], Noosfero.controllers_in_directory('lala')
  end

  def test_should_generate_pattern_for_controllers_in_directory
    Dir.expects(:glob).with(Rails.root.join('app', 'controllers', 'lala', '*_controller.rb')).returns(["app/controllers/lala/system_admin_controller.rb", "app/controllers/lala/environment_admin_controller.rb", "app/controllers/lala/public_controller.rb", "app/controllers/lala/profile_admin_controller.rb"]).once
    assert_equal(/(system_admin|environment_admin|public|profile_admin)/, Noosfero.pattern_for_controllers_in_directory('lala'))
  end

  def test_should_generate_empty_pattern_for_empty_dir
    Dir.stubs(:glob).returns([])
    assert_equal(//, Noosfero.pattern_for_controllers_in_directory('lala'))
  end

  should 'support setting default locale' do
    Noosfero.default_locale = 'pt_BR'
    assert_equal 'pt_BR', Noosfero.default_locale
    Noosfero.default_locale = nil
  end

  should 'identifier format' do
    assert_match /^#{Noosfero.identifier_format}$/, 'bli-bla'
    assert_no_match /^#{Noosfero.identifier_format}$/, 'UPPER'
    assert_match /^#{Noosfero.identifier_format}$/, 'with~tilde'
    assert_match /^#{Noosfero.identifier_format}$/, 'with*asterisk'
    assert_match /^#{Noosfero.identifier_format}$/, 'with.dot'
  end

  should 'provide url options to identify development environment' do
    Rails.expects('env').returns('development')
    Noosfero.expects(:development_url_options).returns({ :port => 9999 })
    assert_equal({:port => 9999}, Noosfero.url_options)
  end

  should 'allow identifier starting with number' do
    assert_match /^#{Noosfero.identifier_format}$/, '129812startingwithnumber'
  end

  should 'change locale temporarily' do
    Noosfero.with_locale('pt') do
      assert_equal 'pt', FastGettext.locale
    end
    assert_equal 'en', FastGettext.locale
  end

  should "use default hostname of default environment as hostname of Noosfero instance" do
    Environment.default.domains << Domain.new(:name => 'thisisdefaulthostname.com').tap do |d| 
      d.is_default = true
    end
    assert_equal 'thisisdefaulthostname.com', Noosfero.default_hostname
  end

  should "use 'localhost' as default hostname of Noosfero instance when has no environments in database" do
    Environment.stubs(:default).returns(nil)
    assert_equal 'localhost', Noosfero.default_hostname
  end

  should "use 'localhost' as default hostname of Noosfero instance when environments table doesn't exists" do
    Environment.stubs(:table_exists?).returns(false)
    assert_equal 'localhost', Noosfero.default_hostname
  end

  should 'be able to override locales' do
    original_locales = Noosfero.locales

    english_only = { 'en' => 'English' }
    Noosfero.locales = english_only
    assert_equal english_only, Noosfero.locales

    # cleanup
    Noosfero.locales = original_locales
  end

end
