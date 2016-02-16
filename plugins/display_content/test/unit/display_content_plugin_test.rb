require_relative '../test_helper'

class DisplayContentPluginTest < ActiveSupport::TestCase

  should "add the jstree javascript" do
    plugin = DisplayContentPlugin.new
    assert plugin.js_files.include?('/javascripts/jstree/jquery.jstree.js')
  end

  should "add new JQuery version" do
    plugin = DisplayContentPlugin.new
    assert plugin.js_files.include?('/javascripts/jstree/_lib/jquery-1.8.3.js')
  end

  should "return DisplayContentBlock in extra_mlocks class method" do
    assert  DisplayContentPlugin.extra_blocks.keys.include?(DisplayContentBlock)
  end

  should "return false for class method has_admin_url?" do
    assert  !DisplayContentPlugin.has_admin_url?
  end

end
