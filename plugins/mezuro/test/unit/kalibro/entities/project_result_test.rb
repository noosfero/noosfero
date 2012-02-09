require "test_helper"
class ProjectResultTest < ActiveSupport::TestCase

  def self.qt_calculator
    result = Kalibro::Entities::ProjectResult.new
    result.project = ProjectTest.qt_calculator
    result.date = DateTime.parse('Thu, 20 Oct 2011 18:26:43.151 +0000')
    result.load_time = 14878
    result.analysis_time = 1022
    result.source_tree = ModuleNodeTest.qt_calculator_tree
    result
  end

  def self.qt_calculator_hash
    {:project => ProjectTest.qt_calculator_hash,
      :date => DateTime.parse('Thu, 20 Oct 2011 18:26:43.151 +0000'),
      :load_time => 14878,
      :analysis_time => 1022,
      :source_tree => ModuleNodeTest.qt_calculator_tree_hash}
  end

  def setup
    @hash = self.class.qt_calculator_hash
    @result = self.class.qt_calculator
  end

  should 'create project result from hash' do
    assert_equal @result, Kalibro::Entities::ProjectResult.from_hash(@hash)
  end

  should 'convert project result to hash' do
    assert_equal @hash, @result.to_hash
  end

  should 'retrieve formatted load time' do
    assert_equal '00:00:14', @result.formatted_load_time
  end

  should 'retrieve formatted analysis time' do
    assert_equal '00:00:01', @result.formatted_analysis_time
  end
  
end