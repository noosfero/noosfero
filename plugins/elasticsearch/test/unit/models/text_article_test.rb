require "#{File.dirname(__FILE__)}/../../test_helper"

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
      assert_includes indexed_fields(TextArticle)[key][:type], value[:type] || 'string'
    end
  end

end
