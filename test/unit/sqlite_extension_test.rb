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

end
