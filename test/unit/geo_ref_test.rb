# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../test_helper'

class GeoRefTest < ActiveSupport::TestCase

  ll = {
    salvador:       [-12.9, -38.5],
    rio_de_janeiro: [-22.9, -43.1],
    new_york:       [ 40.7, -74.0],
    tokyo:          [ 35.6, 139.6]
  }

  should 'calculate the distance between lat,lng points' do
    assert_equal 1215, Noosfero::GeoRef.dist(*(ll[:salvador]+ll[:rio_de_janeiro])).round
    assert_equal 6998, Noosfero::GeoRef.dist(*(ll[:salvador]+ll[:new_york])).round
    assert_equal 17503, Noosfero::GeoRef.dist(*(ll[:salvador]+ll[:tokyo])).round
  end

  should 'calculate the distance between a lat,lng points and a profile' do
    env = fast_create Environment, name: 'SomeSite'
    @acme = Enterprise.create! environment: env, identifier: 'acme', name: 'ACME',
        city: 'Salvador', state: 'Bahia', country: 'BR', lat: -12.9, lng: -38.5
    def sql_dist_to(ll)
      ActiveRecord::Base.connection.execute(
        "SELECT #{Noosfero::GeoRef.sql_dist ll[0], ll[1]} as dist" +
        " FROM profiles WHERE id = #{@acme.id};"
      ).first['dist'].to_f.round
    end
    assert_equal 1215, sql_dist_to(ll[:rio_de_janeiro])
    assert_equal 6998, sql_dist_to(ll[:new_york])
    assert_equal 17503, sql_dist_to(ll[:tokyo])
  end

  def round_ll(ll)
    ll.map{|n| n.is_a?(Float) ? n.to_i : n }
  end

  should 'get lat/lng from address' do
    Rails.cache.clear
    ll = Noosfero::GeoRef.location_to_georef 'Salvador, Bahia, BR'
    assert_equal [-12, -38, :SUCCESS], round_ll(ll)
  end

  should 'get and cache lat/lng from address' do
    Rails.cache.clear
    ll = Noosfero::GeoRef.location_to_georef 'Curitiba, Paraná, BR'
    assert_equal [-25, -49, :SUCCESS], round_ll(ll)
    ll = Noosfero::GeoRef.location_to_georef 'Curitiba, Paraná, BR'
    assert_equal [-25, -49, :SUCCESS, :CACHE], round_ll(ll)
  end

  should 'notify a non existent address' do
    Rails.cache.clear
    orig_env = ENV['RAILS_ENV']
    ENV['RAILS_ENV'] = 'X' # cancel throw for test mode on process_rest_req.
    ll = Noosfero::GeoRef.location_to_georef 'Nowhere, Nocountry, XYZ'
    ENV['RAILS_ENV'] = orig_env # restore value to do not mess with other tests.
    assert_equal [0, 0, :ZERO_RESULTS], round_ll(ll)
  end

end
