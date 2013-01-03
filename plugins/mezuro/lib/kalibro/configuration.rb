class Kalibro::Configuration < Kalibro::Model

  attr_accessor :id, :name, :description

  def id=(value)
    @id = value.to_i
  end

  def self.all
    response = request(:all_configurations)[:configuration]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map {|configuration| new configuration}
  end

end
