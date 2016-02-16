require_relative '../test_helper'
class VideoPluginTest < ActiveSupport::TestCase

  should "return VideoBlock in extra_blocks class method" do
    assert  VideoPlugin.extra_blocks.keys.include?(VideoBlock)
  end

end
