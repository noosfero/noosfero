if !Environment.default
  new_env = Environment.new(:name => ENV['ENVIRONMENT_NAME'],
                      :is_default => true)
  new_env.save
end
