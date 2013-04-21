class Kalibro::Repository < Kalibro::Model
  
  attr_accessor :id, :name, :description, :license, :process_period, :type, :address, :configuration_id, :project_id

  def self.repository_types
    request(:supported_repository_types)[:supported_type].to_a
  end
  
  def self.repositories_of(project_id)
    response = request(:repositories_of, {:project_id => project_id})[:repository]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map {|repository| new repository}
  end

  def id=(value)
    @id = value.to_i
  end

  def process_period=(value)
    @process_period = value.to_i
  end

  def configuration_id=(value)
    @configuration_id = value.to_i
  end

  def process
    self.class.request(:process_repository, {:repository_id => self.id})
  end
  
  def cancel_processing_of_repository
    self.class.request(:cancel_processing_of_repository, {:repository_id => self.id})
  end

  private

  def save_params
    {:repository => self.to_hash, :project_id => project_id}
  end

end
