require_relative 'test_helper'

class SearchTest < ActiveSupport::TestCase

  def setup
    create_and_activate_user
  end

  should 'not list unpublished articles' do
    Article.delete_all
    article = fast_create(Article, :profile_id => person.id, :published => false)
    assert !article.published?
    get "/api/v1/search/article"
    json = JSON.parse(last_response.body)
    assert_empty json
  end

  should 'list articles' do
    fast_create(Article, :profile_id => person.id)
    get "/api/v1/search/article"
    json = JSON.parse(last_response.body)
    assert_not_empty json
  end

  should 'list only articles that has children' do
    article = fast_create(Article, :profile_id => person.id)
    parent = create(Article, :profile_id => person.id, :name => 'parent article')
    child = create(Article, :profile_id => person.id, :parent_id => parent.id, :name => 'child article')

    get "/api/v1/search/article?has_children=true"
    json = JSON.parse(last_response.body)
    assert_equal parent.id, json.first['id']
  end

  should 'invalid search string articles' do
    fast_create(Article, :profile_id => person.id, :name => 'some article')
    get "/api/v1/search/article?query=test"
    json = JSON.parse(last_response.body)
    assert_empty json
  end

  should 'not list articles of wrong type' do
    Article.delete_all
    fast_create(Article, :profile_id => person.id)
    get "/api/v1/search/article?type=TextArticle"
    json = JSON.parse(last_response.body)
    assert_empty json
  end

  should 'list articles of one type' do
    fast_create(Article, :profile_id => person.id)
    article = fast_create(TextArticle, :profile_id => person.id)

    get "/api/v1/search/article?type=TextArticle"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json.first['id']
  end

  should 'list articles of one type and query string' do
    fast_create(Article, :profile_id => person.id, :name => 'some article')
    fast_create(Article, :profile_id => person.id, :name => 'Some thing')
    article = fast_create(TextArticle, :profile_id => person.id, :name => 'Some thing')
    get "/api/v1/search/article?type=TextArticle&query=thing"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.count
    assert_equal article.id, json.first['id']
  end

  should 'not return more entries than page limit' do
    1.upto(5).each do |n|
      fast_create(Article, :profile_id => person.id, :name => "Article #{n}")
    end

    get "/api/v1/search/article?query=Article&per_page=3"
    json = JSON.parse(last_response.body)

    assert_equal 3, json.count
  end

  should 'return entries second page' do
    1.upto(5).each do |n|
      fast_create(Article, :profile_id => person.id, :name => "Article #{n}")
    end

    get "/api/v1/search/article?query=Article&per_page=3&page=2"
    json = JSON.parse(last_response.body)

    assert_equal 2, json.count
  end

  should 'search articles in profile' do
    person2 = fast_create(Person)
    fast_create(Article, :profile_id => person.id)
    fast_create(Article, :profile_id => person.id)
    article = fast_create(Article, :profile_id => person2.id)

    get "/api/v1/search/article?query=Article&profile_id=#{person2.id}"
    json = JSON.parse(last_response.body)
    assert_equal article.id, json.first['id']
  end

  should 'search and return values specified in fields parameter' do
    fast_create(Article, :profile_id => person.id)
    get "/api/v1/search/article?fields=title"
    json = JSON.parse(last_response.body)
    assert_not_empty json
    assert_equal ['title'], json.first.keys
  end

  should 'search with parent' do
    parent = fast_create(Folder, :profile_id => person.id)
    fast_create(Article, :profile_id => person.id)
    article = fast_create(Article, :profile_id => person.id, :parent_id => parent.id)
    get "/api/v1/search/article?parent_id=#{parent.id}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.count
    assert_equal article.id, json.first["id"]
  end

  should 'search filter by category' do
    Article.delete_all
    fast_create(Article, :profile_id => person.id)
    article = fast_create(Article, :profile_id => person.id)
    category = fast_create(Category)
    article.categories<< category
    get "/api/v1/search/article?category_ids=#{category.id}"
    json = JSON.parse(last_response.body)
    assert_equal 1, json.count
    assert_equal article.id, json.first["id"]
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
    assert_equal 2, json.count
    assert_includes ids, json.first["id"]
    assert_includes ids, json.last["id"]
  end

  should 'list only articles that was archived' do
    article1 = fast_create(Article, :profile_id => person.id)
    article2 = fast_create(Article, :profile_id => person.id, archived: true)

    get "/api/v1/search/article?archived=true"
    json = JSON.parse(last_response.body)
    assert_equal [article2.id], json.map {|a| a['id']}
  end

  should 'list articles in search endpoint be deprecated' do
    get "/api/v1/search/article"
    assert_equal Api::Status::DEPRECATED, last_response.status
  end
end
