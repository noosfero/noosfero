require_relative "../test_helper"

class PersonTest < ActionController::TestCase
  include ElasticsearchTestHelper

  def indexed_models
    [Person]
  end

  should "index searchable fields for Person model" do
    Person::SEARCHABLE_FIELDS.each do |key, value|
      assert_includes indexed_fields(Person), key
    end
  end

  should "index control fields for Person model" do
    Person::control_fields.each do |key, value|
      assert_includes indexed_fields(Person), key
      assert_equal indexed_fields(Person)[key][:type], value[:type] || "string"
    end
  end

  should "respond with should method to return public person" do
    assert Person.respond_to? :should
  end

  should "respond with specific sort" do
    assert Person.respond_to? :specific_sort
  end

  should "respond with get_sort_by to order specific sort" do
    assert Person.respond_to? :get_sort_by
  end

  should "return hash to sort by more_active" do
    more_active_hash = { activities_count: { order: :desc } }
    assert_equal more_active_hash, Person.get_sort_by(:more_active)
  end

  should "return hash to sort by more_popular" do
    more_popular_hash = { friends_count: { order: :desc } }
    assert_equal more_popular_hash, Person.get_sort_by(:more_popular)
  end
end
