require "#{File.dirname(__FILE__)}/../../test_helper"
require_relative '../../../helpers/elasticsearch_helper'

class ElasticsearchPluginApiTest < ActiveSupport::TestCase

  include ElasticsearchTestHelper
  include ElasticsearchHelper

  def indexed_models
    [Community, Person]
  end

  def create_instances
    7.times.each {|index| create_user "person #{index}"}
    4.times.each {|index| fast_create Community, name: "community #{index}" }
  end

  should 'show all types avaliable in /search/types endpoint' do
    get "/api/v1/search/types"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal searchable_types.stringify_keys.keys, json["types"]
  end

  should 'respond with endpoint /search with more than 10 results' do
    get "/api/v1/search"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 10, json["results"].count
  end

  should 'respond with query in downcase' do
    get "/api/v1/search?query=person"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 7, json["results"].count
  end

  should 'respond with query in uppercase' do
    get "/api/v1/search?query=PERSON"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 7, json["results"].count
  end

  should 'respond with selected_type' do
    get "/api/v1/search?selected_type=community"
    json = JSON.parse(last_response.body)
    assert_equal 200, last_response.status
    assert_equal 4, json["results"].count
  end
end
