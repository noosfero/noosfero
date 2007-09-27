require "#{File.dirname(__FILE__)}/../test_helper"

class ControllerNamingTest < ActionController::IntegrationTest

  should 'not have controllers with same name in different folders' do
    controllers = Dir.glob("#{RAILS_ROOT}/app/controllers/**/*_controller.rb").map { |item| item.split(/\//).last }
    assert_equal controllers.uniq, controllers
  end

end
