require File.dirname(__FILE__) + '/../test_helper'

class GoogleMapsTest < Test::Unit::TestCase

  def setup
    @domain = fast_create(Domain, :name => 'example-domain', :google_maps_key => 'DOMAIN_KEY')
    # force loading of config at every test
    GoogleMaps.erase_config
  end

  attr_reader :domain

  should 'enable when key on domain is defined' do
    assert GoogleMaps.enabled?(domain.name)
  end

  should 'disable if key on domain is not defined' do
    fast_create(Domain, :name => 'domain-without-key')
    assert !GoogleMaps.enabled?('domain-without-key')
  end

  should 'not crash if config not informed' do
    GoogleMaps.stubs(:config).returns({})
    assert_equal({}, GoogleMaps.config)
  end

  should 'point correctly to google maps' do
    assert_equal 'http://maps.google.com/maps?file=api&amp;v=2&amp;key=DOMAIN_KEY', GoogleMaps.api_url(domain.name)
  end

  should 'provide initial_zoom setting' do
    GoogleMaps.stubs(:config).returns({'initial_zoom' => 2})
    assert_equal 2, GoogleMaps.initial_zoom
  end

  should 'use 4 as default initial_zoom' do
    GoogleMaps.stubs(:config).returns({})
    assert_equal 4, GoogleMaps.initial_zoom
  end

  should 'have different keys to different domains' do
    other_domain = fast_create(Domain, :name => 'different-domain', :google_maps_key => 'DIFFERENT_DOMAIN_KEY')

    assert_equal 'http://maps.google.com/maps?file=api&amp;v=2&amp;key=DOMAIN_KEY', GoogleMaps.api_url(domain.name)
    assert_equal 'http://maps.google.com/maps?file=api&amp;v=2&amp;key=DIFFERENT_DOMAIN_KEY', GoogleMaps.api_url(other_domain.name)
  end
end
