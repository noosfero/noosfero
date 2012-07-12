require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"

class ModuleResultTest < ActiveSupport::TestCase

  def setup
    @hash = ModuleResultFixtures.module_result_hash
    @module_result = ModuleResultFixtures.module_result
  end
  should 'create module result' do
    assert_equal @module_result.date.to_s , Kalibro::ModuleResult.new(@hash).date.to_s
  end
  
  should 'convert module result to hash' do
    assert_equal @hash, @module_result.to_hash
  end

  should 'find module result' do
    date_string = '2012-01-10T16:07:15.442-02:00'
    date = DateTime.parse(date_string)
    request_body = {:project_name => 'Qt-Calculator', :module_name => 'main', :date => date_string}
    response = {:module_result => @hash}
    Kalibro::ModuleResult.expects(:request).with('ModuleResult',:get_module_result, request_body).returns(response)
    assert_equal @module_result.grade, Kalibro::ModuleResult.find_by_project_name_and_module_name_and_date('Qt-Calculator', 'main', date).grade
  end
  
  should 'find all module results' do
    request_body = {:project_name => 'Qt-Calculator', :module_name => 'main'}
    response = {:module_result => @hash}
    Kalibro::ModuleResult.expects(:request).with('ModuleResult',:get_result_history, request_body).returns(response)
    response_array = Kalibro::ModuleResult.all_by_project_name_and_module_name('Qt-Calculator', 'main')
    assert_equal [@module_result].class, response_array.class
    assert_equal @module_result.grade, response_array[0].grade
  end

end
