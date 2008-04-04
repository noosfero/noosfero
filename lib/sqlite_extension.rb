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

end
