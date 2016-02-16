require 'test_helper'

class StoaPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = StoaPlugin.new
  end

  attr_reader :plugin

  should 'display invite control panel button only to users with usp_id' do
    person_with_usp_id = fast_create(Person, :usp_id => 99999999)
    person_without_usp_id = fast_create(Person)
    context = mock()
    StoaPlugin.any_instance.stubs(:context).returns(context)

    context.stubs(:user).returns(nil)
    assert_nil plugin.control_panel_buttons

    context.stubs(:user).returns(person_without_usp_id)
    assert_nil plugin.control_panel_buttons

    context.stubs(:user).returns(person_with_usp_id)
    assert_not_nil plugin.control_panel_buttons
  end
end

