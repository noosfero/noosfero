ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

class Test::Unit::TestCase
  protected
  def assigns(sym)
    @controller.instance_variable_get("@#{sym}")
  end
end
