require File.dirname(__FILE__) + '/../test_helper'

class ArticleCategorizationTest < Test::Unit::TestCase

  should 'use articles_categories table' do
    assert_equal 'articles_categories', ArticleCategorization.table_name
  end

  should 'belong to article' do
    p = create_user('testuser').person
    article = p.articles.build(:name => 'test article'); article.save!
    assert_equal article, ArticleCategorization.new(:article => article).article
  end

  should 'belong to category' do
    category = Category.create!(:name => 'one category', :environment => Environment.default)
    assert_equal category, ArticleCategorization.new(:category => category).category
  end

  should 'create instances for the entire hierarchy' do
    c1 = Category.create!(:name => 'c1', :environment => Environment.default)
    c2 = c1.children.create!(:name => 'c2', :environment => Environment.default)

    p = create_user('testuser').person
    a = p.articles.create!(:name => 'test')

    assert_difference ArticleCategorization, :count, 2 do
      ArticleCategorization.add_category_to_article(c2, a)
    end

    assert_equal 2, ArticleCategorization.find_all_by_article_id(a.id).size
  end

  should 'not duplicate entry for category that is parent of two others' do
    c1 = Category.create!(:name => 'c1', :environment => Environment.default)
    c2 = c1.children.create!(:name => 'c2', :environment => Environment.default)
    c3 = c1.children.create!(:name => 'c3', :environment => Environment.default)

    p = create_user('testuser').person
    a = p.articles.create!(:name => 'test')

    assert_difference ArticleCategorization, :count, 3 do
      ArticleCategorization.add_category_to_article(c2, a)
      ArticleCategorization.add_category_to_article(c3, a)
    end
  end

  should 'remove all instances for a given article' do
    c1 = Category.create!(:name => 'c1', :environment => Environment.default)
    c2 = c1.children.create!(:name => 'c2', :environment => Environment.default)
    c3 = c1.children.create!(:name => 'c3', :environment => Environment.default)

    p = create_user('testuser').person
    a = p.articles.create!(:name => 'test')

    ArticleCategorization.add_category_to_article(c2, a)
    ArticleCategorization.add_category_to_article(c3, a)

    assert_difference ArticleCategorization, :count, -3 do
      ArticleCategorization.remove_all_for(a)
    end
  end

  should 'not duplicate when adding the parent of a category by witch the article is already categorized' do
    c1 = Category.create!(:name => 'c1', :environment => Environment.default)
    c2 = c1.children.create!(:name => 'c2', :environment => Environment.default)

    p = create_user('testuser').person
    a = p.articles.create!(:name => 'test')

    assert_difference ArticleCategorization, :count, 2 do
      ArticleCategorization.add_category_to_article(c2, a)
      ArticleCategorization.add_category_to_article(c1, a)
    end
  end

  should 'make parent real when categorized after child' do
    c1 = Category.create!(:name => 'c1', :environment => Environment.default)
    c2 = c1.children.create!(:name => 'c2', :environment => Environment.default)

    p = create_user('testuser').person
    a = p.articles.create!(:name => 'test')
    ArticleCategorization.add_category_to_article(c2, a)
    ArticleCategorization.add_category_to_article(c1, a)

    assert ArticleCategorization.find(:first, :conditions => [ 'category_id = ? and article_id = ? and not virtual', c1.id, a.id ]), 'categorization must be promoted to not virtual'
  end
end
