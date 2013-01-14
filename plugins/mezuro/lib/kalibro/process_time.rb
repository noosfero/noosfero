class Kalibro::ProcessTime < Kalibro::Model
  
  attr_accessor :state, :time

  def time=(time)
    @time = time.to_i
  end

end
