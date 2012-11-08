class Kalibro::Reading < Kalibro::Model

  attr_accessor :id, :label, :grade, :color

  def self.find(id)
    new request(:get_reading, {:reading_id => id})[:reading]
  end

  def self.readings_of( group_id )
    request(:readings_of, {:group_id => group_id})[:reading].to_a.map { |reading| new reading }
  end
  
  def self.reading_of( range_id )
    new request(:reading_of, {:range_id => range_id} )[:reading]
  end

end
