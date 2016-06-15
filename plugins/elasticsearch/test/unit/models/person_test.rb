require "#{File.dirname(__FILE__)}/../../test_helper"

class PersonTest < ActionController::TestCase

  include ElasticsearchTestHelper

  def indexed_models
    [Person]
  end

  def setup
    super
  end

  should 'index searchable fields for Person model' do
    Person::SEARCHABLE_FIELDS.each do |key, value|
      assert_includes indexed_fields(Person), key
    end
  end

  should 'index control fields for Person model' do
    Person::control_fields.each do |key, value|
      assert_includes indexed_fields(Person), key
      assert_includes indexed_fields(Person)[key][:type], value[:type] || 'string'
    end
  end

end
