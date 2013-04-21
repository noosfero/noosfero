class Kalibro::ReadingGroup < Kalibro::Model

  attr_accessor :id, :name, :description

  def id=(value)
    @id = value.to_i
  end

  def self.all
    response = request(:all_reading_groups)[:reading_group]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map { |reading_group| new reading_group }
  end
  
  def self.reading_group_of( metric_configuration_id )
    new request(:reading_group_of, {:metric_configuration_id => metric_configuration_id} )[:reading_group]
  end

  private

  def self.id_params(id)
    {:group_id => id}
  end
  
  def destroy_params
    {:group_id => self.id}
  end

end
