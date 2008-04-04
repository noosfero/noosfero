require File.dirname(__FILE__) + '/../test_helper'

# if this test is run without SQLite (e.g. with mysql or postgres), the tests
# will just pass. The idea is to test our local extensions to SQLite.
class SQliteExtensionTest < Test::Unit::TestCase

  should 'have sine function' do
    assert_in_delta 0.0, ActiveRecord::Base.connection.execute('select sin(3.14159265358979) as sin').first['sin'], 0.0001
  end

  should 'have cosine function' do
    assert_in_delta -1.0, ActiveRecord::Base.connection.execute('select cos(3.14159265358979) as cos').first['cos'], 0.0001
  end

  should 'have power function' do
    assert_in_delta 8.0, ActiveRecord::Base.connection.execute('select pow(2.0, 3.0) as result').first['result'], 0.0001
  end

  should 'have arcsine function' do
    assert_in_delta Math::PI/2, ActiveRecord::Base.connection.execute('select asin(1) as asin').first['asin'], 0.0001
  end
  
  should 'have arccosine function' do
    assert_in_delta Math::PI, ActiveRecord::Base.connection.execute('select acos(-1.0) as acos').first['acos'], 0.0001
  end

  should 'have radians function' do
    assert_in_delta Math::PI/2, ActiveRecord::Base.connection.execute('select radians(90) as rad').first['rad'], 0.0001
  end

  should 'have square root function' do
    assert_in_delta 1.4142, ActiveRecord::Base.connection.execute('select sqrt(2) as sqrt').first['sqrt'], 0.0001
  end

#  should 'have a distance function' do
#    assert_in_delta 2.28402, ActiveRecord::Base.connection.execute('select dist(32.918593, -96.958444, 32.895155, -96.958444, 3963.19) as dist').first['dist'], 0.0001
#  end

end
