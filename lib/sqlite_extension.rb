if ActiveRecord::Base.connection.adapter_name.downcase == 'sqlite'

  database = ActiveRecord::Base.connection.raw_connection

  database.create_function('pow', 2, :numeric) do |func, base, exponent|
    func.set_result(base.to_f ** exponent.to_f)
  end
  
  database.create_function('sqrt', 1, :numeric) do |func, value|
    func.set_result(Math.sqrt(value))
  end

  database.create_function('radians', 1, :numeric) do |func, value|
    func.set_result(value.to_f * Math::PI / 180.0)
  end

  database.create_function('spheric_distance', 5, :real) do |func, lat1, long1, lat2, long2, radius|
    func.set_result(
      radius.to_f * Math.acos(
	[1,
        Math.cos(lat1.to_f) * Math.cos(long1.to_f) * Math.cos(lat2.to_f) * Math.cos(long2.to_f) + 
         Math.cos(lat1.to_f) * Math.sin(long1.to_f) * Math.cos(lat2.to_f) * Math.sin(long2.to_f) + 
         Math.sin(lat1.to_f) * Math.sin(lat2.to_f)
        ].min
      )
    )
  end
end
