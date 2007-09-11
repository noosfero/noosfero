require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :comatose_pages

  def test_should_use_keywords_as_tags
    article = Article.new
    article.title = 'a test article'
    article.body = 'lalala'
    article.parent = Article.find_by_path('ze')
    article.keywords = 'one, two, three'
    article.save!

    assert article.has_keyword?('one')
    assert article.has_keyword?('two')
    assert article.has_keyword?('three')
  end

end
