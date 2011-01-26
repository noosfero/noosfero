require File.dirname(__FILE__) + '/../test_helper'

class GoogleMapsTest < Test::Unit::TestCase

  def setup
    @domain = fast_create(Domain, :name => 'example-domain', :google_maps_key => 'DOMAIN_KEY')
  end

  attr_reader :domain

  should 'enable when key on domain is defined' do
    assert GoogleMaps.enabled?(domain.name)
  end

  should 'disable if key on domain is not defined' do
    fast_create(Domain, :name => 'domain-without-key')
    assert !GoogleMaps.enabled?('domain-without-key')
  end

  should 'point correctly to google maps' do
    assert_equal 'http://maps.google.com/maps?file=api&amp;v=2&amp;key=DOMAIN_KEY', GoogleMaps.api_url(domain.name)
  end

  should 'provide initial_zoom setting' do
    with_constants :NOOSFERO_CONF => {'googlemaps_initial_zoom' => 2} do
      assert_equal 2, GoogleMaps.initial_zoom
    end
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

  should 'not crash without a domain' do
    Domain.delete_all
    assert_nothing_raised do
      GoogleMaps.key('example.com')
    end
  end

end
