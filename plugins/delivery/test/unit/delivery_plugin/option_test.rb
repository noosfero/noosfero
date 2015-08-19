require "#{File.dirname(__FILE__)}/../../test_helper"

class DeliveryPlugin::OptionTest < ActiveSupport::TestCase

  def setup
    @profile = build(Profile)
    @cycle = build(OrdersCyclePluginCycle, :profile => @profile)
    @delivery_method = build(OrdersCyclePluginMethod, :profile => @profile)
  end

  attr_accessor :profile
  attr_accessor :cycle
  attr_accessor :delivery_method

  should 'be associated with a cycle and a delivery method' do
    option = OrdersCyclePluginOption.new :cycle => @cycle, :delivery_method => @delivery_method
    assert option.valid?
    option = OrdersCyclePluginOption.new
    :wa

    assert !option.valid?
  end

end
