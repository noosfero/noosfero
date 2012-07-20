class Kalibro::Repository < Kalibro::Model
  
  attr_accessor :type, :address, :username, :password

  def self.repository_types
    request("Kalibro", :get_supported_repository_types)[:repository_type].to_a
  end

end
