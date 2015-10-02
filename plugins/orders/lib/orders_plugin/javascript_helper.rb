module OrdersPlugin::JavascriptHelper

  protected

  def j *args
    escape_javascript *args
  end

end
