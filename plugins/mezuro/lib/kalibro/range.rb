class Kalibro::Range < Kalibro::Model
  
  attr_accessor :id, :beginning, :end, :reading_id, :comments

  def id=(value)
    @id = value.to_i
  end

  def beginning=(value)
    @beginning = value.to_f
    @beginning = -1.0/0.0 if value == "-INF"
  end

  def beginning
    if !@beginning.nil?
      case @beginning.to_s
        when "-Infinity": "-INF"
        else @beginning
      end
    end
  end

  def end=(value)
    @end = value.to_f
    @end = 1.0/0.0 if value =~ /INF/
  end

  def end
    if !@end.nil?
      case @end.to_s
        when "Infinity": "INF"
        else @end
      end
    end
  end

  def reading_id=(value)
    @reading_id = value.to_i
  end

  def label
    reading.label
  end

  def grade
    reading.grade
  end

  def color
    reading.color
  end

	def self.ranges_of( metric_configuration_id )
    response = request(:ranges_of, {:metric_configuration_id => metric_configuration_id} )[:range]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map { |range| new range }
  end
  
  def save( metric_configuration_id )
    begin
      self.id = self.class.request(:save_range, {:range => self.to_hash, :metric_configuration_id => metric_configuration_id})[:range_id]
	    true
	  rescue Exception => exception
	    add_error exception
	    false
	  end
  end

  private
  
  def reading
    @reading ||= Kalibro::Reading.find(reading_id)
    @reading
  end

end

