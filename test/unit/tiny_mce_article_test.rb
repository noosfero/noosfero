require File.dirname(__FILE__) + '/../test_helper'

class TinyMceArticleTest < Test::Unit::TestCase

  # this test can be removed when we get real tests for TinyMceArticle 
  should 'be an article' do
    assert_subclass TextArticle, TinyMceArticle
  end

  should 'define description' do
    assert_kind_of String, TinyMceArticle.description
  end

  should 'define short description' do
    assert_kind_of String, TinyMceArticle.short_description
  end

  should 'be found when searching for articles by query' do
    ze = create_user('zezinho').person
    tma = TinyMceArticle.create!(:name => 'test tinymce article', :body => '---', :profile => ze)
    assert_includes TinyMceArticle.find_by_contents('article'), tma
    assert_includes Article.find_by_contents('article'), tma
  end

end
