require_relative '../test_helper'

class CommunityTest < ActiveSupport::TestCase

  include ElasticsearchTestHelper

  def indexed_models
    [Community]
  end

  should 'index searchable fields for Community model' do
    Community::SEARCHABLE_FIELDS.each do |key, value|
      assert_includes indexed_fields(Community), key
    end
  end

  should 'index control fields for Community model' do
    Community::control_fields.each do |key, value|
      assert_includes indexed_fields(Community), key
      assert_equal indexed_fields(Community)[key][:type], value[:type] || 'string'
    end
  end

  should 'respond with should method to return public community' do
    assert Community.respond_to? :should
  end

  should 'respond with specific sort' do
    assert Community.respond_to? :specific_sort
  end

  should 'respond with get_sort_by to order specific sort' do
    assert Community.respond_to? :get_sort_by
  end

  should 'return hash to sort by more_active' do
    more_active_hash = {:activities_count => {order: :desc}}
    assert_equal more_active_hash, Community.get_sort_by(:more_active)
  end

  should 'return hash to sort by more_popular' do
    more_popular_hash = {:members_count => {order: :desc}}
    assert_equal more_popular_hash, Community.get_sort_by(:more_popular)
  end

end
