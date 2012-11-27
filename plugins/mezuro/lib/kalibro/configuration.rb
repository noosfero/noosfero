class Kalibro::Configuration < Kalibro::Model

  attr_accessor :id, :name, :description
  
  def self.configuration_of(repository_id)
    new request(:configuration_of, {:repository_id => repository_id})[:configuration]
  end

  def self.all
    response = request(:all_configurations)[:configuration]
    response = [] if response.nil?
    response = [response] if response.is_a? (Hash) 
    response.map {|configuration| new configuration}
  end


  def update_attributes(attributes={})
    attributes.each { |field, value| send("#{field}=", value) if self.class.is_valid?(field) }
    save
  end

end
