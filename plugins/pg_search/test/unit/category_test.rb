require_relative '../../../../test/test_helper'

class CategoryTest < ActiveSupport::TestCase

  should 'return facets for profiles' do
    profile = fast_create(Profile)
    region = fast_create(Region)
    category = fast_create(Category)
    region2 = fast_create(Region)

    profile.add_category(region)
    profile.add_category(category)

    assert_equivalent [region],
                      Region.pg_search_plugin_profiles_facets(Profile.all)
    assert_equivalent [category],
                      Category.pg_search_plugin_profiles_facets(Profile.all)
  end

  should 'return facets for articles' do
    article = fast_create(Article)
    region = fast_create(Region)
    category = fast_create(Category)
    region2 = fast_create(Region)

    article.add_category(region)
    article.add_category(category)

    assert_equivalent [region],
                      Region.pg_search_plugin_articles_facets(Article.all)
    assert_equivalent [category],
                      Category.pg_search_plugin_articles_facets(Article.all)
  end

  should 'include virtual categories when generating facets' do
    article = fast_create(Article)
    parent = fast_create(Category)
    category = fast_create(Category, parent_id: parent.id)
    article.add_category(category)

    assert_equivalent [category, parent],
                      Category.pg_search_plugin_articles_facets(Article.all)
  end

  should 'only include categories of contents in the scope' do
    article1 = fast_create(Article, name: 'in scope')
    category1 = fast_create(Category)
    article2 = fast_create(Article, name: 'in scope too')
    category2 = fast_create(Category)
    article3 = fast_create(Article, name: 'out of scope')
    category3 = fast_create(Category)

    article1.add_category(category1)
    article2.add_category(category2)
    article3.add_category(category3)

    scope = Article.where("name LIKE '%in scope%'")
    assert_equivalent [category1, category2],
                      Category.pg_search_plugin_articles_facets(scope)
  end
end
