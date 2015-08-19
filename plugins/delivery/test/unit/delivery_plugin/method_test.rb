require "#{File.dirname(__FILE__)}/../../test_helper"

class DeliveryPlugin::MethodTest < ActiveSupport::TestCase

  def setup
    @profile = build(Profile)
  end

  attr_accessor :profile

  should 'have a name and a delivery type' do
    dm = DeliveryPlugin::Method.new :name => 'Delivery Deluxe', :delivery_type => 'deliver', :profile => profile
    assert dm.valid?
    dm = DeliveryPlugin::Method.new :profile => profile
    assert !dm.valid?
  end

  should 'accept only pickup and deliver as delivery types' do
    dm = build(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'unkown', :profile => profile)
    assert !dm.valid?
    dm = build(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'pickup', :profile => profile)
    assert dm.valid?
    dm = build(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'deliver', :profile => profile)
    assert dm.valid?
  end

  should 'filter by delivery types' do
    dm_deliver = create(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'deliver', :profile => profile)
    dm_pickup = create(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'pickup', :profile => profile)
    assert_equal [dm_deliver], DeliveryPlugin::Method.delivery
    assert_equal [dm_pickup], DeliveryPlugin::Method.pickup
  end

  should 'have many delivery options' do
    dm = create(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'deliver', :profile => profile)
    cycle = build(OrdersCyclePlugin::Cycle, :name => 'cycle name', :profile => profile)
    option = create(DeliveryPlugin::Option, :cycle => cycle, :delivery_method => dm)

    assert_equal [option], dm.reload.delivery_options
  end

end
