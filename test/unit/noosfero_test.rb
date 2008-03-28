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

end
