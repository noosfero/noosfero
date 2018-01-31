require_relative '../../../../test/test_helper'

class ArticleTest < ActiveSupport::TestCase

  should 'filter by region' do
    article1 = fast_create(Article)
    article2 = fast_create(Article)
    region = fast_create(Region)
    article1.add_category(region)

    assert_equivalent [article1],
                      Article.pg_search_plugin_by_region(region.id)
  end

  should 'include subcategory results when filtering by category' do
    article = fast_create(Article)
    parent = fast_create(Category)
    category = Category.create!(name: 'sub', environment: Environment.default,
                                parent: parent)
    article.add_category category

    assert_equivalent [article],
                      Article.pg_search_plugin_by_category(parent.id)
  end

end
