require File.dirname(__FILE__) + '/../test_helper'
require 'noosfero'

class NoosferoTest < ActiveSupport::TestCase

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

  should 'allow identifier starting with number' do
    assert_match /^#{Noosfero.identifier_format}$/, '129812startingwithnumber'
  end

  should 'change locale temporarily' do
    Noosfero.with_locale('pt') do
      assert_equal 'pt', FastGettext.locale
    end
    assert_equal 'en', FastGettext.locale
  end

  should 'use terminology with ngettext' do
   Noosfero.stubs(:terminology).returns(UnifreireTerminology.instance)

   Noosfero.with_locale('en') do
     assert_equal 'One institution', n__('One enterprise', '%{num} enterprises', 1)
   end

   Noosfero.with_locale('pt') do
     stubs(:ngettext).with('One institution', '%{num} institutions', 1).returns('Uma instituição')
     assert_equal 'Uma instituição', n__('One enterprise', '%{num} enterprises', 1)
   end
  end

  should "use default hostname of default environment as hostname of Noosfero instance" do
    Environment.default.domains << Domain.new(:name => 'thisisdefaulthostname.com', :is_default => true)
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

end
