require File.dirname(__FILE__) + '/../test_helper'

class TinyMceArticleTest < Test::Unit::TestCase

  # this test can be removed when we get real tests for TinyMceArticle 
  should 'be an article' do
    assert_subclass TextArticle, TinyMceArticle
  end

end
