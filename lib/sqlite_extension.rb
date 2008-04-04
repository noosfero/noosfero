if ActiveRecord::Base.connection.adapter_name =~ /^sqlite$/i

  database = ActiveRecord::Base.connection.raw_connection

  database.create_function('sin', 1, :numeric) do |func, value|
    func.set_result(Math.sin(value))
  end

  database.create_function('cos', 1, :numeric) do |func, value|
    func.set_result(Math.cos(value))
  end

  database.create_function('pow', 2, :numeric) do |func, base, exponent|
    func.set_result(base.to_f ** exponent.to_f)
  end
  
  database.create_function('asin', 1, :numeric) do |func, value|
    func.set_result(Math.asin(value))
  end
  
  database.create_function('acos', 1, :numeric) do |func, value|
    func.set_result(Math.acos(value))
  end
  
  database.create_function('radians', 1, :numeric) do |func, value|
    func.set_result(value.to_f * Math::PI / 180.0)
  end
  
  database.create_function('sqrt', 1, :numeric) do |func, value|
    func.set_result(Math.sqrt(value))
  end

#  database.create_function('dist', 5, :numeric) do |func, lat1, long1, lat2, long2, radius|
#    lat2, long2 = [lat2, long2].map{|l|l * Math::PI/180.0}
#    func.set_result = radius * Math.acos([1,
#      Math.cos(lat1.to_f) * Math.cos(long1.to_f) * Math.cos(lat2.to_f) * Math.cos(long2.to_f) + 
#      Math.cos(lat1.to_f) * Math.sin(long1.to_f) * Math.cos(lat2.to_f) * Math.sin(long2.to_f) + 
#      Math.sin(lat1.to_f) * Math.sin(lat2.to_f)].min)
#  end
end
