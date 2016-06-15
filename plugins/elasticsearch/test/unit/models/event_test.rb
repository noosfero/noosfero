require "#{File.dirname(__FILE__)}/../../test_helper"

class EventTest < ActionController::TestCase

  include ElasticsearchTestHelper

  def indexed_models
    [Event]
  end

  def setup
    super
  end

  should 'index searchable fields for Event model' do
    Event::SEARCHABLE_FIELDS.each do |key, value|
      assert_includes indexed_fields(Event), key
    end
  end

  should 'index control fields for Event model' do
    Event::control_fields.each do |key, value|
      assert_includes indexed_fields(Event), key
      assert_includes indexed_fields(Event)[key][:type], value[:type] || 'string'
    end
  end

end
