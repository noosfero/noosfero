require File.dirname(__FILE__) + '/test_helper'

if ActiveRecord::Base.connection.adapter_name =~ /^sqlite$/i

  # this test only makes sense when using sqlite
  class SQliteExtensionTest < Test::Unit::TestCase
  
    def test_pow_function
      assert_in_delta 8.0, ActiveRecord::Base.connection.execute('select pow(2.0, 3.0) as result').first['result'], 0.0001
    end
  
    def test_radians_function
      assert_in_delta Math::PI/2, ActiveRecord::Base.connection.execute('select radians(90) as rad').first['rad'], 0.0001
    end
  
    def test_sqrt_function
      assert_in_delta 1.4142, ActiveRecord::Base.connection.execute('select sqrt(2) as sqrt').first['sqrt'], 0.0001
    end
  
    def test_spheric_distance_function
      args = [32.918593, -96.958444, 32.951613, -96.958444].map{|l|l * Math::PI/180}
      assert_in_delta 2.28402, ActiveRecord::Base.connection.execute("select spheric_distance(#{args.inspect[1..-2]}, 3963.19) as dist").first['dist'], 0.0001
    end
  
  end

end
