require_relative "../test_helper"

class GoogleMapsTest < ActiveSupport::TestCase

  should 'provide initial_zoom setting' do
    NOOSFERO_CONF.stubs(:[]).with('googlemaps_initial_zoom').returns(2)
    assert_equal 2, GoogleMaps.initial_zoom
  end

  should 'use 4 as default initial_zoom' do
    NOOSFERO_CONF.stubs(:[]).with('googlemaps_initial_zoom').returns(nil)
    assert_equal 4, GoogleMaps.initial_zoom
  end

end
