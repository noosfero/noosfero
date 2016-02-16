require_relative '../test_helper'

class StatisticsPluginTest < ActiveSupport::TestCase

  should "return StatisticsBlock in extra_mlocks class method" do
    assert  StatisticsPlugin.extra_blocks.keys.include?(StatisticsBlock)
  end

end
