require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/project_result_fixtures"

class ProjectResultTest < ActiveSupport::TestCase

  def setup
    @hash = ProjectResultFixtures.qt_calculator_hash
    @result = ProjectResultFixtures.qt_calculator
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

  should 'retrieve module node' do
    node = @result.get_node("main")
    assert_equal @hash[:source_tree][:child][2], node.to_hash
  end

  should 'retrive complex module' do
    node = @result.get_node("org.Window")
    assert_equal @hash[:source_tree][:child][0][:child].first, node.to_hash
  end

  should 'return source tree node when nil is given' do
    assert_equal @hash[:source_tree], @result.node_of(nil).to_hash 
  end
  
  should 'return source tree node when project name is given' do
    assert_equal @hash[:source_tree], @result.node_of(@result.project.name).to_hash 
  end

  should 'return correct node when module name is given' do
    assert_equal @hash[:source_tree][:child][2], @result.node_of("main").to_hash
  end
end
