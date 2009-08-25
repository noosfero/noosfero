require File.dirname(__FILE__) + '/../test_helper'

class TextArticleTest < Test::Unit::TestCase
  
  # mostly dummy test. Can be removed when (if) there are real tests for this
  # this class. 
  should 'inherit from Article' do
    assert_kind_of Article, TextArticle.new
  end

  should 'found TextileArticle by TextArticle class' do
    person = create_user('testuser').person
    article = TextileArticle.create!(:name => 'textile article test', :profile => person)
    assert_includes TextArticle.find(:all), article
  end
  
  should 'found TextileArticle by TextArticle indexes' do
    person = create_user('testuser').person
    article = TextileArticle.create!(:name => 'found article test', :profile => person)
    assert_equal TextileArticle.find_by_contents('found'), TextArticle.find_by_contents('found')
  end

  should 'remove comments from TextArticle body' do
    person = create_user('testuser').person
    article = TextArticle.create!(:profile => person, :name => 'article', :body => "the <!-- comment --> article ...")
    assert_equal "the  article ...", article.body
  end

end
