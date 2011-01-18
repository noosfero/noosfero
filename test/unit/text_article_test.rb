require File.dirname(__FILE__) + '/../test_helper'

class TextArticleTest < Test::Unit::TestCase
  
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

  should 'be translatable' do
    assert_kind_of Noosfero::TranslatableContent, TextArticle.new
  end

  should 'return article icon name' do
    assert_equal Article.icon_name, TextArticle.icon_name
  end

  should 'return blog icon name if the article is a blog post' do
    blog = fast_create(Blog)
    article = TextArticle.new(:parent => blog)
    assert_equal Blog.icon_name, TextArticle.icon_name(article)
  end

end
