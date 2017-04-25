require_relative '../test_helper'
require_relative '../../lib/nested_helper/profile'

class TextArticleTest < ActionController::TestCase

  include ElasticsearchTestHelper

  def indexed_models
    [TextArticle]
  end

  should 'index searchable fields for TextArticle model' do
    TextArticle::SEARCHABLE_FIELDS.each do |key, value|
      assert_includes indexed_fields(TextArticle), key
    end
  end

  should 'index control fields for TextArticle model' do
    TextArticle::control_fields.each do |key, value|
      assert_includes indexed_fields(TextArticle), key
      assert_equal indexed_fields(TextArticle)[key][:type], value[:type] || 'string'
    end
  end

  should 'respond with should method to return public text_article' do
    assert TextArticle.respond_to? :should
  end

  should 'respond with specific sort' do
    assert TextArticle.respond_to? :specific_sort
  end

  should 'respond with get_sort_by to order specific sort' do
    assert TextArticle.respond_to? :get_sort_by
  end

  should 'return hash to sort by most commented' do
    more_active_hash = {:comments_count => {order: :desc}}
    assert_equal more_active_hash, TextArticle.get_sort_by(:more_comments)
  end

  should 'return hash to sort by more popular' do
    more_popular_hash = {:hits => {order: :desc}}
    assert_equal more_popular_hash, TextArticle.get_sort_by(:more_popular)
  end

  should 'respond with nested_filter' do
    assert TextArticle.respond_to? :nested_filter
  end

  should 'have NestedProfile_filter in nested_filter' do
    assert TextArticle.nested_filter.include? NestedProfile.filter
  end

end
