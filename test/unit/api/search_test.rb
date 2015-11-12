require_relative 'test_helper'

class SearchTest < ActiveSupport::TestCase

  def setup
    @person = create_user('testing').person
  end
  attr_reader :person

  should 'not list unpublished articles' do
    Article.delete_all
    article = fast_create(Article, :profile_id => person.id, :published => false)
    assert !article.published?  	
    get "/api/v1/search/article"
    json = JSON.parse(last_response.body)    
    assert_empty json['articles']
  end

  should 'list articles' do
    fast_create(Article, :profile_id => person.id)
    get "/api/v1/search/article"
    json = JSON.parse(last_response.body)
    assert_not_empty json['articles']
  end

  should 'invalid search string articles' do
    fast_create(Article, :profile_id => person.id, :name => 'some article')
    get "/api/v1/search/article?query=test"
    json = JSON.parse(last_response.body)    
    assert_empty json['articles']
  end

  should 'do not list articles of wrong type' do
    fast_create(Article, :profile_id => person.id)
    get "/api/v1/search/article?type=TinyMceArticle"
    json = JSON.parse(last_response.body)
    assert_empty json['articles']
  end

  should 'list articles of one type' do
    fast_create(Article, :profile_id => person.id)
    article = fast_create(TinyMceArticle, :profile_id => person.id)
  
    get "/api/v1/search/article?type=TinyMceArticle"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json['articles'].first['id']
  end

  should 'list articles of one type and query string' do
    fast_create(Article, :profile_id => person.id, :name => 'some article')
    fast_create(Article, :profile_id => person.id, :name => 'Some thing')
    article = fast_create(TinyMceArticle, :profile_id => person.id, :name => 'Some thing')
    get "/api/v1/search/article?type=TinyMceArticle&query=thing"
    json = JSON.parse(last_response.body)
    assert_equal 1, json['articles'].count
    assert_equal article.id, json['articles'].first['id']
  end

  should 'not return more entries than page limit' do
    1.upto(5).each do |n|
      fast_create(Article, :profile_id => person.id, :name => "Article #{n}")
    end

    get "/api/v1/search/article?query=Article&per_page=3"
    json = JSON.parse(last_response.body)

    assert_equal 3, json['articles'].count
  end

  should 'return entries second page' do
    1.upto(5).each do |n|
      fast_create(Article, :profile_id => person.id, :name => "Article #{n}")
    end

    get "/api/v1/search/article?query=Article&per_page=3&page=2"
    json = JSON.parse(last_response.body)

    assert_equal 2, json['articles'].count
  end

  should 'search articles in profile' do
    person2 = fast_create(Person)
    fast_create(Article, :profile_id => person.id)
    fast_create(Article, :profile_id => person.id)
    article = fast_create(Article, :profile_id => person2.id)

    get "/api/v1/search/article?query=Article&profile_id=#{person2.id}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json['articles'].first['id']
  end

  should 'search and return values specified in fields parameter' do
    fast_create(Article, :profile_id => person.id)
    get "/api/v1/search/article?fields=title"
    json = JSON.parse(last_response.body)
    assert_not_empty json['articles']
    assert_equal ['title'], json['articles'].first.keys
  end

  should 'search with parent' do
    parent = fast_create(Folder, :profile_id => person.id)
    fast_create(Article, :profile_id => person.id)
    article = fast_create(Article, :profile_id => person.id, :parent_id => parent.id)
    get "/api/v1/search/article?parent_id=#{parent.id}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json['articles'].count
    assert_equal article.id, json['articles'].first["id"]
  end  

  should 'search filter by category' do
    Article.delete_all
    fast_create(Article, :profile_id => person.id)
    article = fast_create(Article, :profile_id => person.id)
    category = fast_create(Category)
    article.categories<< category
    get "/api/v1/search/article?category_ids=#{category.id}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json['articles'].count
    assert_equal article.id, json['articles'].first["id"]
  end  

  should 'search filter by more than one category' do
    Article.delete_all
    fast_create(Article, :profile_id => person.id)
    article1 = fast_create(Article, :profile_id => person.id)
    article2 = fast_create(Article, :profile_id => person.id)
    category1 = fast_create(Category)
    category2 = fast_create(Category)
    article1.categories<< category1
    article2.categories<< category2
    get "/api/v1/search/article?category_ids[]=#{category1.id}&category_ids[]=#{category2.id}"
    json = JSON.parse(last_response.body)
    ids = [article1.id, article2.id]
    assert_equal 2, json['articles'].count
    assert_includes ids, json['articles'].first["id"]
    assert_includes ids, json['articles'].last["id"]
  end

end
