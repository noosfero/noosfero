class Kalibro::Reading < Kalibro::Model

  attr_accessor :id, :label, :grade, :color

  def self.find(id)
    new request(:get_reading, {:reading_id => id})[:reading]
  end

  def self.readings_of( group_id )
    response = request(:readings_of, {:group_id => group_id})[:reading]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map { |reading| new reading }
  end
  
  def self.reading_of( range_id )
    new request(:reading_of, {:range_id => range_id} )[:reading]
  end

  def id=(value)
    @id = value.to_i
  end

  def grade=(value)
    @grade = value.to_f
  end

  def save(reading_group_id)
    begin
      self.id = self.class.request(:save_reading, {:reading => self.to_hash, :group_id => reading_group_id})[:reading_id]
      true
	  rescue Exception => exception
	    add_error exception
	    false
    end
  end

end
