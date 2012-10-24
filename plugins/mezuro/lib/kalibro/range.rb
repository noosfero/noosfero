class Kalibro::Range < Kalibro::Model
  
  attr_accessor :beginning, :end, :label, :grade, :color, :comments

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
    @end = 1.0/0.0 if value == "INF"
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
		@color.nil? ? "#e4ca2d" : @color.gsub(/^ff/, "#")
	end
	
	def color=(new_color)
		@color = new_color.gsub(/^#/, "ff")
	end
	
end
