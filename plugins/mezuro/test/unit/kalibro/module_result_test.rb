require "test_helper"

require "#{RAILS_ROOT}/plugins/mezuro/test/fixtures/module_result_fixtures"

class ModuleResultTest < ActiveSupport::TestCase

  def setup
    @hash = ModuleResultFixtures.module_result_hash
    @module_result = ModuleResultFixtures.module_result
  end
  should 'create module result' do
    assert_equal @module_result.date, Kalibro::ModuleResult.new(@hash).date
  end
  
  should 'convert module result to hash' do
    assert_equal @hash, @module_result.to_hash
  end

  should 'find module result' do
    date_string = '2012-01-10T16:07:15.442-02:00'
    date = DateTime.parse(date_string)
    request_body = {:project_name => 'Qt-Calculator', :module_name => 'main', :date => date_string}
    response = {:module_result => @hash}
    Kalibro::ModuleResult.expects(:request).with(:get_module_result, request_body).returns(response)
    assert_equal @module_result, Kalibro::ModuleResult.find_module_result('Qt-Calculator', 'main', date)
  end

end
