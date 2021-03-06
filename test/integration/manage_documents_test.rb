require_relative "../test_helper"

class ManageDocumentsTest < ActionDispatch::IntegrationTest
  all_fixtures

  def test_creation_of_a_new_article
    user = create_user("myuser")
    user.activate!

    login_as_rails5("myuser")
    assert_tag tag: "a", attributes: { href: "/myprofile/#{user.login}" }

    get "/myprofile/myuser"
    assert_response :success
    assert_tag tag: "a", attributes: { href: "/myprofile/myuser/cms" }

    get "/myprofile/myuser/cms/new"
    assert_response :success
    assert_tag tag: "a", attributes: { href: "/myprofile/myuser/cms/new?type=TextArticle" }

    get "/myprofile/myuser/cms/new?type=TextArticle"
    assert_response :success
    assert_tag tag: "form", attributes: { action: "/myprofile/myuser/cms/new", method: /post/i }

    assert_difference "Article.count" do
      post "/myprofile/myuser/cms/new",
           params: { type: "TextArticle",
                     article: { name: "my article",
                                body: "this is the body of the article" } }
      follow_redirect!
    end

    assert_response :success
    a = Article.find_by(path: "my-article")
    assert_equal "/myuser/#{a.slug}", path
  end

  def test_update_of_an_existing_article
    profile = create_user("myuser").person
    profile.user.activate!
    article = create_article(profile, name: "my-article")
    article.save!

    login_as_rails5("myuser")
    assert_tag tag: "a", attributes: { href: "/myprofile/#{profile.identifier}" }

    get "/myprofile/myuser"
    assert_response :success
    assert_tag tag: "a", attributes: { href: "/myprofile/myuser/cms" }

    get "/myprofile/myuser/cms"
    assert_response :success
    assert_tag tag: "a", attributes: { href: "/myprofile/myuser/cms/edit/#{article.id}" }

    get "/myprofile/myuser/cms/#{article.id}/edit"
    assert_response :success
    assert_tag tag: "form", attributes: { action: "/myprofile/myuser/cms/#{article.id}/edit", method: /post/i }

    assert_no_difference "Article.count" do
      post "/myprofile/myuser/cms/#{article.id}/edit", params: { article: { name: "my article",
                                                                            body: "this is the body of the article" } }
      follow_redirect!
    end

    article.reload
    assert_equal "this is the body of the article", article.body

    assert_response :success
    a = Article.find_by path: "my-article"
    assert_equal "/myuser/#{a.slug}", path
  end

  def test_removing_an_article
    profile = create_user("myuser").person
    profile.user.activate!
    article = create_article(profile, name: "my-article")
    article.save!

    login_as_rails5("myuser")

    assert_tag tag: "a", attributes: { href: "/myprofile/#{profile.identifier}" }
    get "/myprofile/myuser"
    assert_response :success

    assert_tag tag: "a", attributes: { href: "/myprofile/myuser/cms" }
    get "/myprofile/myuser/cms"
    assert_response :success

    assert_tag tag: "a", attributes: { href: "/myprofile/myuser/cms/#{article.id}/destroy", "data-confirm" => /Are you sure/ }
    post "/myprofile/myuser/cms/#{article.id}/destroy"
    follow_redirect!

    assert_response :success
    assert_equal "/myuser", path

    # the article was actually deleted
    assert_raise ActiveRecord::RecordNotFound do
      Article.find(article.id)
    end
  end

  protected

    def create_article(profile, options)
      article = TextArticle.new(options)
      article.profile = profile
      article.save!
      article
    end
end
