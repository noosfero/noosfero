require_relative "../test_helper"

class ArticleCategorizationTest < ActiveSupport::TestCase

  should 'use articles_categories table' do
    assert_equal 'articles_categories', ArticleCategorization.table_name
  end

  should 'belong to article' do
    p = create_user('testuser').person
    article = p.articles.build(:name => 'test article'); article.save!
    categorization = ArticleCategorization.new
    categorization.article = article
    assert_equal article, categorization.article
  end

  should 'belong to category' do
    category = create_category('one category')
    categorization = ArticleCategorization.new
    categorization.category = category
    assert_equal category, categorization.category
  end

  should 'create instances for the entire hierarchy' do
    c1 = create_category('c1')
    c2 = create_category('c2', c1)

    p = create_user('testuser').person
    a = p.articles.create!(:name => 'test')

    assert_difference 'ArticleCategorization.count(:category_id)', 2 do
      ArticleCategorization.add_category_to_article(c2, a)
    end

    assert_equal 2, ArticleCategorization.find_all_by_article_id(a.id).size
  end

  should 'not duplicate entry for category that is parent of two others' do
    c1 = create_category('c1')
    c2 = create_category('c2', c1)
    c3 = create_category('c3', c1)

    p = create_user('testuser').person
    a = p.articles.create!(:name => 'test')

    assert_difference 'ArticleCategorization.count(:category_id)', 3 do
      ArticleCategorization.add_category_to_article(c2, a)
      ArticleCategorization.add_category_to_article(c3, a)
    end
  end

  should 'remove all instances for a given article' do
    c1 = create_category('c1')
    c2 = create_category('c2', c1)
    c3 = create_category('c3', c1)

    p = create_user('testuser').person
    a = p.articles.create!(:name => 'test')

    ArticleCategorization.add_category_to_article(c2, a)
    ArticleCategorization.add_category_to_article(c3, a)

    assert_difference 'ArticleCategorization.count(:category_id)', -3 do
      ArticleCategorization.remove_all_for(a)
    end
  end

  should 'not duplicate when adding the parent of a category by witch the article is already categorized' do
    c1 = create_category('c1')
    c2 = create_category('c2', c1)

    p = create_user('testuser').person
    a = p.articles.create!(:name => 'test')

    assert_difference 'ArticleCategorization.count(:category_id)', 2 do
      ArticleCategorization.add_category_to_article(c2, a)
      ArticleCategorization.add_category_to_article(c1, a)
    end
  end

  should 'make parent real when categorized after child' do
    c1 = create_category('c1')
    c2 = create_category('c2', c1)

    p = create_user('testuser').person
    a = p.articles.create!(:name => 'test')
    ArticleCategorization.add_category_to_article(c2, a)
    ArticleCategorization.add_category_to_article(c1, a)

    assert ArticleCategorization.where('category_id = ? and article_id = ? and not virtual', c1.id, a.id).first, 'categorization must be promoted to not virtual'
  end

  private

  def create_category(name, parent = nil)
    c = Category.new(:name => name)
    c.environment = Environment.default
    c.parent = parent
    c.save!
    c
  end
end
