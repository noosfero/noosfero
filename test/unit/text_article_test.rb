require File.dirname(__FILE__) + '/../test_helper'

class TextArticleTest < Test::Unit::TestCase
  
  # mostly dummy test. Can be removed when (if) there are real tests for this
  # this class. 
  should 'inherit from Article' do
    assert_kind_of Article, TextArticle.new
  end
end
