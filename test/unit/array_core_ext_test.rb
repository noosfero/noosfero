require_relative "../test_helper"

# tests for Array core extension. See lib/noosfero/core_ext/array.rb
class StringCoreExtTest < ActiveSupport::TestCase

  should 'allow uniq by a block' do
    array = [0,1,2,3,4,5,6]
    assert_equal [0,1], array.uniq_by {|number| number%2 }
  end

end
