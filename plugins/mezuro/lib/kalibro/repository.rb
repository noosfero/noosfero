class Kalibro::Repository < Kalibro::Model
  
  attr_accessor :id, :name, :description, :license, :process_period, :type, :address, :configuration_id

  def self.repository_types
    request("Repository", :supported_repository_types)[:repository_type].to_a
  end

  def self.repository_of(processing_id)
    new request("Repository", :repository_of, {:processing_id => processing_id})[:repository]
  end
  
  def self.repositories_of(project_id)
    request("Repository", :repositories_of, {:project_id => project_id})[:repository].to_a.map { |repository| new repository }
  end

  def process_repository
    self.class.request("Repository", :process_repository, {:repository_id => self.id});
  end
  
  def cancel_processing_of_repository
    self.class.request("Repository", :cancel_processing_of_repository, {:repository_id => self.id});
  end

end
