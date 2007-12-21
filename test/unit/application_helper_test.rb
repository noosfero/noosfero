require File.dirname(__FILE__) + '/../test_helper'

class ApplicationHelperTest < Test::Unit::TestCase

  include ApplicationHelper

  should 'calculate correctly partial for object' do
    self.stubs(:params).returns({:controller => 'test'})

    File.expects(:exists?).with("#{RAILS_ROOT}/app/views/test/_float.rhtml").returns(false)
    File.expects(:exists?).with("#{RAILS_ROOT}/app/views/test/_numeric.rhtml").returns(true).times(2)
    File.expects(:exists?).with("#{RAILS_ROOT}/app/views/test/_runtime_error.rhtml").returns(true).at_least_once

    assert_equal 'numeric', partial_for_class(Float)
    assert_equal 'numeric', partial_for_class(Numeric)
    assert_equal 'runtime_error', partial_for_class(RuntimeError)
  end

end
