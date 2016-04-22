if ApplicationRecord.connection.adapter_name.downcase == 'sqlite'

  database = ApplicationRecord.connection.raw_connection

  database.create_function('pow', 2, 1) do |func, base, exponent|
    func.set_result(base.to_f ** exponent.to_f)
  end

  database.create_function('sqrt', 1, 1) do |func, value|
    func.set_result(Math.sqrt(value))
  end

  database.create_function('radians', 1, 1) do |func, value|
    func.set_result(value.to_f * Math::PI / 180.0)
  end

  database.create_function('spheric_distance', 5, 1) do |func, lat1, long1, lat2, long2, radius|
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
