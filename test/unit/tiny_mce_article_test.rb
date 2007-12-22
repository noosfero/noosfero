require File.dirname(__FILE__) + '/../test_helper'

class TinyMceArticleTest < Test::Unit::TestCase

  should 'be an article' do
    assert_subclass Article, TinyMceArticle
  end

end
