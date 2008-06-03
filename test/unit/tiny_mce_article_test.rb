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

end
