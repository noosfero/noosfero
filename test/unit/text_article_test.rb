require File.dirname(__FILE__) + '/../test_helper'

class TextArticleTest < ActiveSupport::TestCase
  
  # mostly dummy test. Can be removed when (if) there are real tests for this
  # this class. 
  should 'inherit from Article' do
    assert_kind_of Article, TextArticle.new
  end

  should 'found TextileArticle by TextArticle class' do
    person = create_user('testuser').person
    article = fast_create(TextileArticle, :name => 'textile article test', :profile_id => person.id)
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

  should 'escape malformed html tags' do
    person = create_user('testuser').person
    article = TextArticle.new(:profile => person)
    article.name = "<h1 Malformed >> html >>></a>< tag"
    article.abstract = "<h1 Malformed <<h1>>< html >< tag"
    article.body = "<h1><</h2< Malformed >> html >< tag"
    article.valid?

    assert_no_match /[<>]/, article.name
    assert_no_match /[<>]/, article.abstract
    assert_no_match /[<>]/, article.body
  end

end
