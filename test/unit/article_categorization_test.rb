require File.dirname(__FILE__) + '/../test_helper'

class ArticleCategorizationTest < Test::Unit::TestCase

  should 'use articles_categories table' do
    assert_equal 'articles_categories', ArticleCategorization.table_name
  end

  should 'belong to article' do
    p = create_user('testuser').person
    article = p.articles.build(:name => 'test article'); article.save!
    assert_equal article, ArticleCategorization.create!(:article => article).article
  end

  should 'belong to category' do
    category = Category.create!(:name => 'one category', :environment => Environment.default)
    assert_equal category, ArticleCategorization.create!(:category => category).category
  end

end
