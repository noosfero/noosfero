require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersPlugin::ItemTest < ActiveSupport::TestCase

  def setup
    @item = build(OrdersPlugin::Item,
     :quantity_shipped => 1.0, :quantity_consumer_ordered => 2.0, :quantity_accepted => 3.0,
     :price_shipped => 10.0, :price_consumer_ordered => 20.0, :price_accepted => 30.0)
  end

  should 'calculate prices' do
  end

end
