require_relative "../test_helper"

# if this test is run without SQLite (e.g. with mysql or postgres), the tests
# will just pass. The idea is to test our local extensions to SQLite.
class SQliteExtensionTest < ActiveSupport::TestCase

  if ActiveRecord::Base.connection.adapter_name =~ /^sqlite$/i

    should 'have power function' do
      assert_in_delta 8.0, ActiveRecord::Base.connection.execute('select pow(2.0, 3.0) as result').first['result'], 0.0001
    end

    should 'have radians function' do
      assert_in_delta Math::PI/2, ActiveRecord::Base.connection.execute('select radians(90) as rad').first['rad'], 0.0001
    end

    should 'have square root function' do
      assert_in_delta 1.4142, ActiveRecord::Base.connection.execute('select sqrt(2) as sqrt').first['sqrt'], 0.0001
    end

    should 'have a distance function' do
      args = [32.918593, -96.958444, 32.951613, -96.958444].map{|l|l * Math::PI/180}
      assert_in_delta 2.28402, ActiveRecord::Base.connection.execute("select spheric_distance(#{args.inspect[1..-2]}, 3963.19) as dist").first['dist'], 0.0001
    end

  else

    should 'just pass (not using SQLite)' do
      assert true
    end

  end

end
