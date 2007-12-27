require File.dirname(__FILE__) + '/../test_helper'

class TextileArticleTest < Test::Unit::TestCase
  
  def setup
    @profile = create_user('testing').person
  end
  attr_reader :profile

  should 'provide a proper short description' do
    # not test the actual text, though
    TextileArticle.stubs(:==).with(Article).returns(true)
    assert_not_equal Article.short_description, TextileArticle.short_description
  end

  should 'provide a proper description' do
    # not test the actual text, though
    TextileArticle.stubs(:==).with(Article).returns(true)
    assert_not_equal Article.description, TextileArticle.description
  end

  should 'convert Textile to HTML' do
    assert_equal '<p><strong>my text</strong></p>', TextileArticle.new(:body => '*my text*').to_html
  end

end
