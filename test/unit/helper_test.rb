require_relative "../test_helper"

class HelperTest < ActiveSupport::TestCase

  should 'assert_equivalent be true for the same arrays' do
    a1 = [1,2,3]
    a2 = [1,2,3]
    assert_equivalent a1, a2
  end

  should 'assert_equivalent be true for equivalent arrays' do
    a1 = [1,2,3]
    a2 = [3,2,1]
    assert_equivalent a1, a2
  end

  should 'assert_equivalent be true for equivalent arrays independent of parameter order' do
    a1 = [1,2,3]
    a2 = [3,2,1]
    assert_equivalent a2, a1
  end

  should 'assert_equivalent be false for different arrays' do
    a1 = [1,2,3]
    a2 = [4,2,1]
    assert_raise Minitest::Assertion do
      assert_equivalent(a1, a2)
    end
  end

  should 'assert_equivalent be false for different arrays independent of parameter order' do
    a1 = [1,2,3]
    a2 = [4,2,1]
    assert_raise Minitest::Assertion do
      assert_equivalent(a2, a1)
    end
  end

  should 'assert_equivalent be false for arrays with different sizes' do
    a1 = [1,2,3]
    a2 = [1,2,3,4]
    assert_raise Minitest::Assertion do
      assert_equivalent(a1, a2)
    end
  end

  should 'assert_equivalent be false for arrays with same elements duplicated' do
    a1 = [2,2,3]
    a2 = [2,3,3]
    assert_raise Minitest::Assertion do
      assert_equivalent(a1, a2)
    end
  end

  should 'assert_equivalent be false for arrays with same elements duplicated of different sizes' do
    a1 = [2,2,3]
    a2 = [2,3,3,3]
    assert_raise Minitest::Assertion do
      assert_equivalent(a1, a2)
    end
  end
end
