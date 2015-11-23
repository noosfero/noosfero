class DeliveryPlugin::Base < Noosfero::Plugin

  def stylesheet?
    true
  end

  def js_files
    ['delivery'].map{ |j| "javascripts/#{j}" }
  end

end


