require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"

class ModuleResultTest < ActiveSupport::TestCase

  def setup
    @hash = ModuleResultFixtures.module_result_hash
    @module_result = ModuleResultFixtures.module_result
  end

  should 'create module result' do
    assert_equal @hash[:id] , Kalibro::ModuleResult.new(@hash).id
  end
  
  should 'convert module result to hash' do
    assert_equal @hash, @module_result.to_hash
  end

  should 'find module result' do
    response = {:module_result => @hash}
    Kalibro::ModuleResult.expects(:request).with(:get_module_result, {:module_result_id => @module_result.id}).returns(response)
    assert_equal @module_result.grade, Kalibro::ModuleResult.find(@module_result.id).grade
  end
  
  should 'return children of a module result' do
    response = {:module_result => [@hash]}
    Kalibro::ModuleResult.expects(:request).with(:children_of, {:module_result_id => @module_result.id}).returns(response)
    assert @hash[:id], @module_result.children.first.id
  end

  should 'return history of a module result' do
    Kalibro::ModuleResult.expects(:request).with(:history_of_module, {:module_result_id => @module_result.id}).returns({:date_module_result => [DateModuleResultFixtures.date_module_result_hash]})
    assert_equal DateModuleResultFixtures.date_module_result_hash[:module_result][:id], Kalibro::ModuleResult.history_of(@module_result.id).first.module_result.id
  end

end
