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

  should 'have an associated profile' do
    article = Article.new(:title => 'someuser', :body => "some text")
    article.parent = Comatose::Page.root
    article.save!

    Profile.expects(:find_by_identifier).with("someuser")
    article.profile
  end

  should 'get associated profile from name of root page' do
    article = Article.new(:title => "test article", :body => 'some sample text')
    article.parent = Article.find_by_path('ze')
    article.save!

    assert_equal 'ze/test-article', article.full_path

    Profile.expects(:find_by_identifier).with("ze")
    article.profile
  end

end
