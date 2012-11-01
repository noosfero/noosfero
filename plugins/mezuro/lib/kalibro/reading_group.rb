class Kalibro::ReadingGroup < Kalibro::Model

  attr_accessor :id, :name, :description

  def self.find(id)
    new request("ReadingGroup", :get_reading_group, {:group_id => id})[:reading_group]
  end

  def self.all
    request("ReadingGroup", :all_reading_groups)[:reading_group].to_a.map { |reading_group| new reading_group }
  end
  
  def self.reading_group_of( metric_configuration_id )
    new request("ReadingGroup", :reading_group_of, {:metric_configuration_id => metric_configuration_id} )[:reading_group]
  end

  private

  def self.exists_params(id)
    {:group_id => id}
  end
  
  def destroy_params
    {:group_id => self.id}
  end

end
