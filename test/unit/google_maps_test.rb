require File.dirname(__FILE__) + '/../test_helper'

class GoogleMapsTest < Test::Unit::TestCase

  def setup
    # force loading of config at every test
    GoogleMaps.erase_config
  end

  should 'enable when key is defined' do
    GoogleMaps.stubs(:config).returns({ 'key' => 'MYKEY' })
    assert GoogleMaps.enabled?
  end

  should 'disable if key not defined' do
    GoogleMaps.stubs(:config).returns({})
    assert !GoogleMaps.enabled?
  end

  should 'not crash if config not informed' do
    GoogleMaps.stubs(:config).returns({})
    assert_equal '', GoogleMaps.key
  end

  should 'point correctly to google maps' do
    GoogleMaps.expects(:key).returns('MY_FUCKING_KEY')
    assert_equal 'http://maps.google.com/maps?file=api&amp;v=2&amp;key=MY_FUCKING_KEY', GoogleMaps.api_url
  end

  should 'provide initial_zoom setting' do
    GoogleMaps.stubs(:config).returns({'initial_zoom' => 2})
    assert_equal 2, GoogleMaps.initial_zoom
  end

  should 'use 4 as default initial_zoom' do
    GoogleMaps.stubs(:config).returns({})
    assert_equal 4, GoogleMaps.initial_zoom
  end

end
