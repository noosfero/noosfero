require "#{File.dirname(__FILE__)}/../../test_helper"

class CommunityTest < ActionController::TestCase

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

end
