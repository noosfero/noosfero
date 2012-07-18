require File.dirname(__FILE__) + '/../test_helper'

class GoogleMapsTest < ActiveSupport::TestCase

  should 'provide initial_zoom setting' do
    with_constants :NOOSFERO_CONF => {'googlemaps_initial_zoom' => 2} do
      assert_equal 2, GoogleMaps.initial_zoom
    end
  end

  should 'use 4 as default initial_zoom' do
    GoogleMaps.stubs(:config).returns({})
    assert_equal 4, GoogleMaps.initial_zoom
  end

end
