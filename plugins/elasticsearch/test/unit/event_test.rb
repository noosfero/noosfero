require "#{File.dirname(__FILE__)}/../test_helper"
require_relative '../../lib/nested_helper/profile'

class EventTest < ActionController::TestCase

  include ElasticsearchTestHelper

  def indexed_models
    [Event]
  end

  should 'index searchable fields for Event model' do
    Event::SEARCHABLE_FIELDS.each do |key, value|
      assert_includes indexed_fields(Event), key
    end
  end

  should 'index control fields for Event model' do
    Event::control_fields.each do |key, value|
      assert_includes indexed_fields(Event), key
      assert_equal indexed_fields(Event)[key][:type], value[:type] || 'string'
    end
  end

  should 'respond with should method to return public event' do
    assert Event.respond_to? :should
  end

  should 'respond with nested_filter' do
    assert Event.respond_to? :nested_filter
  end

  should 'have NestedProfile_filter in nested_filter' do
    assert Event.nested_filter.include? NestedProfile.filter
  end

end
