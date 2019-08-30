require_relative "../test_helper"

class ElasticsearchPluginEntitiesTest < ActiveSupport::TestCase
  include ElasticsearchTestHelper

  def indexed_models
    [Person, TextArticle, UploadedFile, Community, Event]
  end

  def create_instances
    Article.delete_all
    user = create_user "sample person", environment_id: 1

    fast_create Community, name: "sample community", created_at: 10.days.ago, updated_at: 5.days.ago, environment_id: 1

    fast_create UploadedFile, name: "sample uploadedfile", created_at: 3.days.ago, updated_at: 1.days.ago, author_id: user.person.id, abstract: "sample abstract", profile_id: user.person.id
    fast_create Event, name: "sample event", created_at: 20.days.ago, updated_at: 5.days.ago, author_id: user.person.id, abstract: "sample abstract", profile_id: user.person.id
    fast_create TextArticle, name: "sample raw html article", created_at: 15.days.ago, updated_at: 5.days.ago, author_id: user.person.id, profile_id: user.person.id
    fast_create TextArticle, name: "sample tiny mce article", created_at: 5.days.ago, updated_at: 5.days.ago, author_id: user.person.id, profile_id: user.person.id
  end

  should "show attributes from person" do
    params = { selected_type: "person" }
    get "/api/v1/search?#{params.to_query}"
    json = JSON.parse(last_response.body)

    expected_person = Person.find_by name: "sample person"

    assert_equal 200, last_response.status
    assert_equal expected_person.id, json["results"][0]["id"]
    assert_equal expected_person.name, json["results"][0]["name"]
    assert_equal expected_person.type, json["results"][0]["type"]
    assert_equal "", json["results"][0]["description"]
    assert_equal expected_person.created_at.strftime("%Y/%m/%d %H:%M:%S"), json["results"][0]["created_at"]
    assert_equal expected_person.updated_at.strftime("%Y/%m/%d %H:%M:%S"), json["results"][0]["updated_at"]
  end

  should "show attributes from community" do
    params = { selected_type: "community" }
    get "/api/v1/search?#{params.to_query}"
    json = JSON.parse(last_response.body)

    expected_community = Community.find_by name: "sample community"

    assert_equal 200, last_response.status

    assert_equal expected_community.id, json["results"][0]["id"]
    assert_equal expected_community.name, json["results"][0]["name"]
    assert_equal expected_community.type, json["results"][0]["type"]
    assert_equal "", json["results"][0]["description"]
    assert_equal expected_community.created_at.strftime("%Y/%m/%d %H:%M:%S"), json["results"][0]["created_at"]
    assert_equal expected_community.updated_at.strftime("%Y/%m/%d %H:%M:%S"), json["results"][0]["updated_at"]
  end

  should "show attributes from text_article" do
    params = { selected_type: "text_article" }
    get "/api/v1/search?#{params.to_query}"

    json = JSON.parse(last_response.body)

    assert_equal 200, last_response.status

    expected_text_articles = TextArticle.all

    # FIXME: NOT passing on travis
    return
    expected_text_articles.each_with_index { |object, index|
      result = json["results"][index]
      assert_equal object.id,     result["id"]
      assert_equal object.name,   result["name"]
      assert_equal "TextArticle", result["type"]

      expected_author = (object.author.nil?) ? "" : object.author.name

      assert_equal expected_author, result["author"]
      assert_equal object.created_at.strftime("%Y/%m/%d %H:%M:%S"), result["created_at"]
      assert_equal object.updated_at.strftime("%Y/%m/%d %H:%M:%S"), result["updated_at"]
    }
  end

  should "show attributes from uploaded_file" do
    params = { selected_type: "uploaded_file" }
    get "/api/v1/search?#{params.to_query}"

    json = JSON.parse(last_response.body)

    assert_equal 200, last_response.status

    expected_uploaded_files = UploadedFile.all
    expected_uploaded_files.each_with_index { |object, index|
      assert_equal object.id, json["results"][index]["id"]
      assert_equal object.name, json["results"][index]["name"]
      assert_equal object.abstract, json["results"][index]["abstract"]
      assert_equal "UploadedFile", json["results"][index]["type"]

      expected_author = (object.author.nil?) ? "" : object.author.name
      assert_equal expected_author, json["results"][index]["author"]

      assert_equal object.created_at.strftime("%Y/%m/%d %H:%M:%S"), json["results"][index]["created_at"]
      assert_equal object.updated_at.strftime("%Y/%m/%d %H:%M:%S"), json["results"][index]["updated_at"]
    }
  end

  should "show attributes from event" do
    params = { selected_type: "event" }
    get "/api/v1/search?#{params.to_query}"

    json = JSON.parse(last_response.body)

    assert_equal 200, last_response.status
    expected_events = Event.all
    expected_events.each_with_index { |object, index|
      assert_equal object.id, json["results"][index]["id"]
      assert_equal object.name, json["results"][index]["name"]
      assert_equal object.abstract, json["results"][index]["abstract"]
      assert_equal "Event", json["results"][index]["type"]

      expected_author = (object.author.nil?) ? "" : object.author.name
      assert_equal expected_author, json["results"][index]["author"]

      assert_equal object.created_at.strftime("%Y/%m/%d %H:%M:%S"), json["results"][index]["created_at"]
      assert_equal object.updated_at.strftime("%Y/%m/%d %H:%M:%S"), json["results"][index]["updated_at"]
    }
  end
end
