require_relative '../test_helper'

class DisplayContentPluginTest < ActiveSupport::TestCase

  should "return DisplayContentBlock in extra_mlocks class method" do
    assert  DisplayContentPlugin.extra_blocks.keys.include?(DisplayContentBlock)
  end

  should "return false for class method has_admin_url?" do
    assert  !DisplayContentPlugin.has_admin_url?
  end

end
