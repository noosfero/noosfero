class Kalibro::Range < Kalibro::Model
  
  attr_accessor :id, :beginning, :end, :reading_id, :comments

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

  def grade=(value)
    @grade = value.to_f
  end

	def mezuro_color
		@color.nil? ? "e4ca2d" : @color.gsub(/^ff/, "")
	end
	
	def self.ranges_of( metric_configuration_id )
    request(:ranges_of, {:metric_configuration_id => metric_configuration_id} )[:range].to_a.map { |range| new range }
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

end
