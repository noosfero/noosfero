require File.dirname(__FILE__) + '/../test_helper'

class ConsumptionTest < ActiveSupport::TestCase
  fixtures :consumptions

  should 'escape malformed html tags' do
    consumption = Consumption.new
    consumption.aditional_specifications = "<h1 Malformed >> html >< tag"
    consumption.valid?

    assert_no_match /[<>]/, consumption.aditional_specifications
  end

end
