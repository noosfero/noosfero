require "test_helper"
class BaseToolTest < ActiveSupport::TestCase

  def self.analizo
    total_cof = NativeMetricTest.total_cof
    amloc = NativeMetricTest.amloc
    base_tool = Kalibro::Entities::BaseTool.new
    base_tool.name = 'Analizo'
    base_tool.supported_metrics = [total_cof, amloc]
    base_tool
  end

  def self.analizo_hash
    total_cof_hash = NativeMetricTest.total_cof_hash
    amloc_hash = NativeMetricTest.amloc_hash
    {:name => 'Analizo',
     :supported_metric => [total_cof_hash, amloc_hash]}
  end

  def setup
    @hash = self.class.analizo_hash
    @base_tool = self.class.analizo
  end

  should 'create base tool from hash' do
    assert_equal @base_tool, Kalibro::Entities::BaseTool.from_hash(@hash)
  end

  should 'convert base tool to hash' do
    assert_equal @hash, @base_tool.to_hash
  end

end