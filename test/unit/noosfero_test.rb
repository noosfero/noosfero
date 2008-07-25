require File.dirname(__FILE__) + '/../test_helper'
require 'noosfero'

class NoosferoTest < Test::Unit::TestCase

  def test_should_list_controllers_in_directory
    Dir.expects(:glob).with("#{RAILS_ROOT}/app/controllers/lala/*_controller.rb").returns(["app/controllers/lala/system_admin_controller.rb", "app/controllers/lala/environment_admin_controller.rb", "app/controllers/lala/public_controller.rb", "app/controllers/lala/profile_admin_controller.rb"]).once
    assert_equal ["system_admin", "environment_admin", "public", "profile_admin"], Noosfero.controllers_in_directory('lala')
  end

  def test_should_generate_pattern_for_controllers_in_directory
    Dir.expects(:glob).with("#{RAILS_ROOT}/app/controllers/lala/*_controller.rb").returns(["app/controllers/lala/system_admin_controller.rb", "app/controllers/lala/environment_admin_controller.rb", "app/controllers/lala/public_controller.rb", "app/controllers/lala/profile_admin_controller.rb"]).once
    assert_equal(/(system_admin|environment_admin|public|profile_admin)/, Noosfero.pattern_for_controllers_in_directory('lala'))
  end

  def test_should_generate_empty_pattern_for_empty_dir
    Dir.stubs(:glob).returns([])
    assert_equal(//, Noosfero.pattern_for_controllers_in_directory('lala'))
  end

  should 'support setting default locale' do
    Noosfero.default_locale = 'pt_BR'
    assert_equal 'pt_BR', Noosfero.default_locale
  end

  should 'identifier format' do
    assert_match /^#{Noosfero.identifier_format}$/, 'bli-bla'
    assert_no_match /^#{Noosfero.identifier_format}$/, 'UPPER'
    assert_no_match /^#{Noosfero.identifier_format}$/, '129812startingwithnumber'
    assert_match /^#{Noosfero.identifier_format}$/, 'with~tilde'
    assert_match /^#{Noosfero.identifier_format}$/, 'with.dot'
  end

  should 'delegate terminology' do
    Noosfero.terminology.expects(:get).with('lalala').returns('lelele')
    assert_equal 'lelele', Noosfero.term('lalala')
  end

  should 'use default terminology by default' do
    assert_equal 'lalalalala', Noosfero.term('lalalalala')
  end

  should 'provide url options to identify development environment' do
    ENV.expects(:[]).with('RAILS_ENV').returns('development')
    Noosfero.expects(:development_url_options).returns({ :port => 9999 })
    assert_equal({:port => 9999}, Noosfero.url_options)
  end

end
