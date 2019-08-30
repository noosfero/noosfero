require_relative "../test_helper"

class ContentViewerControllerTest < ActionDispatch::IntegrationTest
  all_fixtures

  def setup
    @controller = ContentViewerController.new

    @profile = create_user("testinguser").person
    @environment = @profile.environment
  end
  attr_reader :profile, :environment

  def test_should_display_page
    page = profile.articles.build(name: "test")
    page.save!

    get page_path(profile.identifier, page: ["test"])
    assert_response :success
    assert_equal page, assigns(:page)
  end

  def test_should_display_homepage
    a = profile.articles.build(name: "test")
    a.save!
    profile.home_page = a
    profile.save!

    get page_path(profile.identifier, page: ["test"])

    assert_response :success
    assert_template "view_page"
    assert_equal a, assigns(:page)
  end

  def test_should_get_not_found_error_for_unexisting_page
    get page_path("aprofile", page: ["some_unexisting_page"])
    assert_response :missing
  end

  def test_should_get_not_found_error_for_unexisting_profile
    Profile.delete_all
    get page_path("some_unexisting_profile", page: [])
    assert_response :missing
  end

  should "produce a download-link when view page is true" do
    profile = create_user("someone").person
    html = UploadedFile.create! uploaded_data: fixture_file_upload("/files/500.html", "text/html"), profile: profile
    html.save!
    get page_path("someone", page: ["500"]), params: { view: true }

    assert_response :success
    assert_select "a.download-link"
  end

  should "download file when view page is blank" do
    profile = create_user("someone").person
    image = UploadedFile.create! uploaded_data: fixture_file_upload("/files/rails.png", "image/png"), profile: profile
    image.save!

    get page_path("someone", page: ["rails"])

    assert_response :redirect
    assert_redirected_to image.public_filename
  end

  should "display image on a page when article is image and has a view param" do
    profile = create_user("someone").person
    image = UploadedFile.create! uploaded_data: fixture_file_upload("/files/rails.png", "image/png"), profile: profile
    image.save!

    get page_path("someone", page: ["rails"]), params: { view: true }

    assert_response :success
    assert_template "view_page"
    assert_match /text\/html/, @response.headers["Content-Type"]
  end

  should "produce a download-link when article is not text/html" do
    # for example, RSS feeds
    profile = create_user("someone").person
    page = profile.articles.build(name: "myarticle", body: "the body of the text")
    page.save!

    feed = RssFeed.new(name: "testfeed")
    feed.profile = profile
    feed.save!

    get page_path("someone", page: ["testfeed"])

    assert_response :success
    assert_match /^text\/xml/, @response.headers["Content-Type"]

    assert_equal feed.data, @response.body
  end

  should "produce rss feed for podcasting" do
    profile = create_user("someone2").person
    blog = Blog.create!(name: "My blog", profile: profile)
    file = UploadedFile.create!(
      uploaded_data: fixture_file_upload("/files/rails.png", "image/png"),
      profile: profile,
      parent: blog
    )
    file.save!

    get page_path(profile.identifier, page: blog.feed.url[:page])
    assert_response :success
    assert_match /.*<enclosure url="[^"]*rails[^"]*".*/, @response.body
  end

  should "display current article's tags" do
    page = profile.articles.create!(name: "myarticle",
                                    body: "test article",
                                    tag_list: "tag1, tag2")

    get page_path(profile.identifier, page: ["myarticle"])
    assert_tag tag: "div", attributes: { id: "article-tags" }, descendant: {
      tag: "a",
      attributes: { href: "/profile/#{profile.identifier}/tags/tag1" }
    }
    assert_tag tag: "div", attributes: { id: "article-tags" }, descendant: {
      tag: "a",
      attributes: { href: "/profile/#{profile.identifier}/tags/tag2" }
    }

    assert_tag tag: "div", attributes: { id: "article-tags" },
               descendant: { tag: "h3", content: "Tags" }
  end

  should "display image label on article image" do
    page = TextArticle.create!(
      profile: profile,
      name: "myarticle",
      image_builder: {
        uploaded_data: fixture_file_upload("/files/tux.png", "image/png"),
        label: "test-label"
      }
    )
    get page_path(profile.identifier, page: page.url[:page])
    assert_match /test-label/, @response.body
  end

  should "not display current article's tags" do
    page = profile.articles.create!(name: "myarticle", body: "test article")

    get page_path(profile.identifier, page: ["myarticle"])
    !assert_tag tag: "div", attributes: { id: "article-tags" }
    !assert_tag tag: "div", attributes: { id: "article-tags" }, descendant: { content: /This article's tags:/ }
  end

  should "give 404 status on unexisting article" do
    profile.articles.delete_all
    get page_path(profile.identifier, page: ["VERY-UNPROBABLE-PAGE"])
    assert_response 404
  end

  should "not show private content to members" do
    community = fast_create(Community)
    admin = fast_create(Person)
    community.add_member(admin)

    folder = fast_create(Folder, profile_id: community.id, published: false, access: Entitlement::Levels.levels[:self])
    community.add_member(profile)
    login_as_rails5(profile.identifier)

    get page_path(community.identifier, page: [folder.path])

    assert_template "shared/access_denied"
  end

  should "show private content to profile moderators" do
    community = Community.create!(name: "testcomm")
    community.articles.create!(name: "test",
                               published: true,
                               access: Entitlement::Levels.levels[:self])
    community.add_moderator(profile)

    login_as_rails5(profile.identifier)

    get page_path(community.identifier, page: ["test"])
    assert_response :success
  end

  should "show private content to profile admins" do
    community = Community.create!(name: "testcomm")
    community.articles.create!(name: "test",
                               published: true,
                               access: Entitlement::Levels.levels[:self])
    community.add_admin(profile)

    login_as_rails5(profile.identifier)

    get page_path(community.identifier, page: ["test"])
    assert_response :success
  end

  should "load the correct profile when using hosted domain" do
    profile = create_user("mytestuser").person
    profile.domains << Domain.create!(name: "micojones.net")
    profile.save!

    get page_path(profile.identifier, page: [])

    assert_equal profile, assigns(:profile)
  end

  should "give link to edit the article for owner" do
    login_as_rails5("testinguser")
    get page_path("testinguser", page: []), params: { toolbar: true }, xhr: true
    assert_tag tag: "ul", attributes: { class: "noosfero-dropdown-menu" }, descendant: { tag: "a", attributes: { href: "/myprofile/testinguser/cms/#{@profile.home_page.id}/edit" } }
  end
  should "not give link to edit the article for non-logged-in people" do
    get page_path("testinguser", page: []), params: { toolbar: true }, xhr: true
    !assert_tag tag: "div", attributes: { id: "article-actions" }, descendant: { tag: "a", attributes: { href: "/myprofile/testinguser/cms/#{@profile.home_page.id}/edit" } }
  end
  should "not give link to edit article for other people" do
    login_as_rails5(create_user("anotheruser").login)

    get page_path("testinguser", page: []), params: { toolbar: true }, xhr: true
    !assert_tag tag: "div", attributes: { id: "article-actions" }, descendant: { tag: "a", attributes: { href: "/myprofile/testinguser/cms/#{@profile.home_page.id}/edit" } }
  end

  should "give link to create new article" do
    login_as_rails5("testinguser")
    get page_path("testinguser", page: []), params: { toolbar: true }, xhr: true
    assert_tag tag: "ul", attributes: { class: "noosfero-dropdown-menu" }, descendant: { tag: "a", attributes: { href: "/myprofile/testinguser/cms/new" } }
  end
  should "give no link to create new article for non-logged in people " do
    get page_path("testinguser", page: []), params: { toolbar: true }, xhr: true
    !assert_tag tag: "ul", attributes: { class: "noosfero-dropdown-menu" }, descendant: { tag: "a", attributes: { href: "/myprofile/testinguser/cms/new" } }
  end
  should "give no link to create new article for other people" do
    login_as_rails5(create_user("anotheruser").login)
    get page_path("testinguser", page: []), params: { toolbar: true }, xhr: true
    !assert_tag tag: "ul", attributes: { class: "noosfero-dropdown-menu" }, descendant: { tag: "a", attributes: { href: "/myprofile/testinguser/cms/new" } }
  end

  should "give link to create new article inside folder" do
    login_as_rails5("testinguser")
    folder = Folder.create!(name: "myfolder", profile: @profile)
    get page_path("testinguser", page: ["myfolder"]), params: { toolbar: true }, xhr: true
    assert_tag tag: "ul", attributes: { class: "noosfero-dropdown-menu" }, descendant: { tag: "a", attributes: { href: "/myprofile/testinguser/cms/new?parent_id=#{folder.id}" } }
  end

  should "not give access to private articles if logged off" do
    profile = Community.create!(name: "test profile", identifier: "test_profile")
    intranet = Folder.create!(name: "my_intranet", profile: profile, published: false, access: Entitlement::Levels.levels[:self])

    get page_path("test_profile", page: ["my-intranet"])

    assert_template "shared/access_denied"
  end

  should "not give access to private articles if logged in but not member" do
    login_as_rails5("testinguser")
    profile = Community.create!(name: "test profile", identifier: "test_profile")
    intranet = Folder.create!(name: "my_intranet", profile: profile, published: false, access: Entitlement::Levels.levels[:self])

    get page_path("test_profile", page: ["my-intranet"])

    assert_template "shared/access_denied"
  end

  should "not give access to private articles if logged in and only member" do
    person = create_user("test_user").person
    profile = Profile.create!(name: "test profile", identifier: "test_profile")
    intranet = Folder.create!(name: "my_intranet", profile: profile, published: false, access: Entitlement::Levels.levels[:self])
    profile.affiliate(person, Profile::Roles.member(profile.environment.id))
    login_as_rails5("test_user")

    get page_path("test_profile", page: ["my-intranet"])

    assert_template "shared/access_denied"
  end

  should "give access to private articles if logged in and moderator" do
    person = create_user("test_user").person
    profile = Profile.create!(name: "test profile", identifier: "test_profile")
    intranet = Folder.create!(name: "my_intranet",
                              profile: profile,
                              published: true,
                              access: Entitlement::Levels.levels[:self])
    profile.affiliate(person, Profile::Roles.moderator(profile.environment.id))
    login_as_rails5("test_user")

    get page_path("test_profile", page: ["my-intranet"])

    assert_template "view_page"
  end

  should "give access to private articles if logged in and admin" do
    person = create_user("test_user").person
    profile = Profile.create!(name: "test profile", identifier: "test_profile")
    intranet = Folder.create!(name: "my_intranet",
                              profile: profile,
                              published: true,
                              access: Entitlement::Levels.levels[:self])
    profile.affiliate(person, Profile::Roles.admin(profile.environment.id))
    login_as_rails5("test_user")

    get page_path("test_profile", page: ["my-intranet"])

    assert_template "view_page"
  end

  should "list comments if article has them, even if new comments are not allowed" do
    page = profile.articles.create!(name: "myarticle", body: "the body of the text", accept_comments: false)
    page.comments.create!(author: profile, body: "list my comment")
    get page_path(profile.identifier, page: ["myarticle"])

    assert_tag tag: "ul", attributes: { id: "article-comments-list" }
  end

  should "order comments according to comments ordering option" do
    article = fast_create(Article, profile_id: profile.id)
    for n in 1..24
      article.comments.create!(author: profile, title: "some title #{n}", body: "some body #{n}")
    end

    get page_path(profile.identifier, page: article.path.split("/"))

    for i in 1..12
      assert_tag tag: "p", attributes: { class: "comment-text" }, content: "some body #{i + 12}"
      !assert_tag tag: "p", attributes: { class: "comment-text" }, content: "some body #{i}"
    end

    get page_path(profile.identifier, page: article.path.split("/"), comment_page: 1), params: { comment_order: "oldest" }, xhr: true

    for i in 1..12
      assert_tag tag: "p", attributes: { class: "comment-text" }, content: "some body #{i}"
      !assert_tag tag: "p", attributes: { class: "comment-text" }, content: "some body #{i + 12}"
    end
  end

  should "redirect to new article path under an old path" do
    p = create_user("test_user").person
    a = p.articles.create(name: "old-name")
    old_path = a.path
    a.name = "new-name"
    a.save!

    get page_path(p.identifier, page: old_path)

    assert_response :redirect
    assert_redirected_to host: p.default_hostname, controller: "content_viewer", action: "view_page", profile: p.identifier, page: a.path
  end

  should "load new article name equal of another article old name" do
    p = create_user("test_user").person
    a1 = p.articles.create!(name: "old-name")
    old_path = a1.path
    a1.name = "new-name"
    a1.save!
    a2 = p.articles.create!(name: "old-name")

    get page_path(p.identifier, page: old_path)

    assert_equal a2, assigns(:page)
  end

  should "redirect to article with most recent version with the name if there is no article with the name" do
    p = create_user("test_user").person
    a1 = p.articles.create!(name: "old-name")
    old_path = a1.path
    a1.name = "new-name"
    a1.save!
    a2 = p.articles.create!(name: "old-name")
    a2.name = "other-new-name"
    a2.save!

    get page_path(p.identifier, page: old_path)

    assert_response :redirect
    assert_redirected_to host: p.default_hostname, controller: "content_viewer", action: "view_page", profile: p.identifier, page: a2.path
  end

  should "display current article's versions" do
    page = TextArticle.create!(name: "myarticle", body: "test article", display_versions: true, profile: profile)
    page.body = "test article edited"; page.save

    get versions_path(profile.identifier, page: ["myarticle"])
    assert_select "ul#article-versions a[href=\"http://#{profile.environment.default_hostname}/#{profile.identifier}/#{page.path}?version=1\"]"
  end

  should "display correct author for each article versions" do
    community = fast_create(Community)
    author1 = create_user.person
    author2 = create_user.person
    article = create(TextArticle, name: "article", body: "first version", display_versions: true,
                                  profile: community, author: author1, last_changed_by: author1)

    article.body = "second version"
    article.last_changed_by = author2
    article.save

    get versions_path(community.identifier, page: article.path)
    assert_tag tag: "span", attributes: { class: "updated-by" },
               child: { tag: "a", content: author1.name }
    assert_tag tag: "span", attributes: { class: "updated-by" },
               child: { tag: "a", content: author2.name }
  end

  should "fetch correct article version" do
    page = TextArticle.create!(name: "myarticle", body: "original article", display_versions: true, profile: profile)
    page.body = "edited article"; page.save

    get page_path(profile.identifier, page: ["myarticle"]), params: { version: 1 }

    assert_tag tag: "div", attributes: { class: /article-body/ }, content: /original article/
  end

  should "display current article if version does not exist" do
    page = TextArticle.create!(name: "myarticle", body: "original article", display_versions: true, profile: profile)
    page.body = "edited article"; page.save

    get page_path(profile.identifier, page: ["myarticle"]), params: { version: "bli" }

    assert_tag tag: "div", attributes: { class: /article-body/ }, content: /edited article/
  end

  should "display differences between article's versions" do
    page = TextArticle.create!(name: "myarticle", body: "original article", display_versions: true, profile: profile)
    page.body = "edited article"; page.save

    get versions_diff_path(profile.identifier, page: ["myarticle"]), params: { v1: 1, v2: 2 }

    assert_tag tag: "li", attributes: { class: /del/ }, content: /original/
    assert_tag tag: "li", attributes: { class: /ins/ }, content: /edited/
    assert_response :success
  end

  should "not return an article of a different user" do
    p1 = create_user("test_user").person
    a = p1.articles.create!(name: "old-name")
    old_path = a.path
    a.name = "new-name"
    a.save!

    p2 = create_user("another_user").person

    get page_path(p2.identifier, page: old_path)

    assert_response :missing
  end

  should "not show a profile in an environment that is not its home environment" do
    p = create(Profile, identifier: "mytestprofile", name: "My test profile", environment: Environment.default)

    current = fast_create(Environment, name: "test environment")
    current.domains.create!(name: "example.com")

    get page_path("mytestprofile", page: [])
    assert_response :missing
  end

  should "list unpublished posts to owner with a different class" do
    login_as_rails5("testinguser")
    blog = Blog.create!(name: "A blog test", profile: profile)
    blog.posts.to_a << TextArticle.create!(name: "Post", profile: profile,
                                           parent: blog,
                                           published: false,
                                           access: Entitlement::Levels.levels[:self])

    get page_path(profile.identifier, page: [blog.path])
    assert_tag tag: "div", attributes: { class: /private/ }
  end

  should "not list unpublished posts to a not logged person" do
    blog = Blog.create!(name: "A blog test", profile: profile)
    blog_posts = blog.posts
    blog_posts.to_a << TextArticle.create!(name: "Post", profile: profile, parent: blog, published: false, access: Entitlement::Levels.levels[:self])

    get page_path(profile.identifier, page: [blog.path])
    !assert_tag tag: "a", content: "Post"
  end

  should "display pagination links of blog" do
    blog = Blog.create!(name: "A blog test", profile: profile, posts_per_page: 5)
    for n in 1..10
      blog.posts.to_a << TextArticle.create!(name: "Post #{n}", profile: profile, parent: blog)
    end
    assert_equal 10, blog.posts.size

    get page_path(profile.identifier, page: [blog.path])
    assert_tag tag: "a", attributes: { href: "/#{profile.identifier}/#{blog.path}?npage=2", rel: "next" }
  end

  should "display first page of blog posts" do
    blog = Blog.create!(name: "My blog", profile: profile, posts_per_page: 5)
    for n in 1..10
      blog.children << TextArticle.create!(name: "Post #{n}", profile: profile, parent: blog)
    end
    assert_equal 10, blog.posts.size

    get page_path(profile.identifier, page: [blog.path])
    for n in 1..5
      !assert_tag tag: "h1", attributes: { class: "title" }, descendant: { tag: "a", attributes: { href: /\/#{profile.identifier}\/my-blog\/post-#{n}/ }, content: "Post #{n}" }
    end
    for n in 6..10
      assert_tag tag: "h1", attributes: { class: "title" }, descendant: { tag: "a", attributes: { href: /\/#{profile.identifier}\/my-blog\/post-#{n}/ }, content: "Post #{n}" }
    end
  end

  should "display others pages of blog posts" do
    blog = Blog.create!(name: "My blog", profile: profile, posts_per_page: 5)
    for n in 1..10
      blog.children << TextArticle.create!(name: "Post #{n}", profile: profile, parent: blog)
    end
    assert_equal 10, blog.posts.size

    get page_path(profile.identifier, page: [blog.path]), params: { npage: 2 }
    for n in 1..5
      assert_tag tag: "h1", attributes: { class: "title" }, descendant: { tag: "a", attributes: { href: /\/#{profile.identifier}\/my-blog\/post-#{n}/ }, content: "Post #{n}" }
    end
    for n in 6..10
      !assert_tag tag: "h1", attributes: { class: "title" }, descendant: { tag: "a", attributes: { href: /\/#{profile.identifier}\/my-blog\/post-#{n}/ }, content: "Post #{n}" }
    end
  end

  should "set year and month filter from URL params" do
    blog = Blog.create!(name: "blog", profile: profile)
    profile.articles << blog

    past_post = create(TextArticle, name: "past post", profile: profile, parent: blog, published_at: blog.created_at - 1.year)
    current_post = TextArticle.create!(name: "current post", profile: profile, parent: blog)
    blog.children << past_post
    blog.children << current_post

    year, month = profile.blog.created_at.year.to_s, "%02d" % profile.blog.created_at.month

    get page_path(profile.identifier, page: [profile.blog.path], year: year), params: { month: month }

    !assert_tag tag: "a", content: past_post.title
    assert_tag tag: "a", content: current_post.title
  end

  should "give link to create new article inside folder when view child of folder" do
    login_as_rails5("testinguser")
    folder = Folder.create!(name: "myfolder", profile: @profile)
    folder.children << TextArticle.new(name: "children-article", profile: @profile)
    get page_path("testinguser", page: ["myfolder", "children-article"]), params: { toolbar: true }, xhr: true
    assert_tag tag: "ul", attributes: { class: "noosfero-dropdown-menu" }, descendant: { tag: "a", attributes: { href: "/myprofile/testinguser/cms/new?parent_id=#{folder.id}" } }
  end

  should "display 'New article' when create children of folder" do
    login_as_rails5(profile.identifier)
    a = Folder.new(name: "article folder"); profile.articles << a; a.save!
    Article.stubs(:short_description).returns("bli")
    get page_path(profile.identifier, page: [a.path]), params: { toolbar: true }, xhr: true
    assert_tag tag: "a", content: "New article"
  end

  should "display 'New post' when create children of blog" do
    login_as_rails5(profile.identifier)
    a = Blog.create!(name: "article folder", profile: profile)
    Article.stubs(:short_description).returns("bli")
    get page_path(profile.identifier, page: [a.path]), params: { toolbar: true }, xhr: true
    assert_tag tag: "a", content: "New post"
  end

  should "display same label for new article button of parent" do
    login_as_rails5(profile.identifier)
    a = Blog.create!(name: "article folder", profile: profile)
    Article.stubs(:short_description).returns("bli")
    t = TextArticle.create!(name: "first post", parent: a, profile: profile)
    get page_path(profile.identifier, page: [t.path]), params: { toolbar: true }, xhr: true
    assert_tag tag: "a", content: "New post"
  end

  should "display button to remove article" do
    login_as_rails5(profile.identifier)
    t = TextArticle.create!(name: "article to destroy", profile: profile)
    get page_path(profile.identifier, page: [t.path]), params: { toolbar: true }, xhr: true
    assert_tag tag: "a", content: "Delete", attributes: { href: "/myprofile/#{profile.identifier}/cms/destroy/#{t.id}" }
  end

  should "not display delete button for homepage" do
    login_as_rails5(profile.identifier)
    page = profile.home_page
    get page_path(profile.identifier, page: page.path), params: { toolbar: true }, xhr: true
    !assert_tag tag: "a", content: "Delete", attributes: { href: "/myprofile/#{profile.identifier}/cms/destroy/#{page.id}" }
  end

  should "add meta tag to rss feed on view blog" do
    login_as_rails5(profile.identifier)
    profile.articles << Blog.new(name: "Blog", profile: profile)
    get page_path(profile.identifier, page: ["blog"])
    assert_tag tag: "link", attributes: { rel: "alternate", type: "application/rss+xml", title: "Blog", href: "http://#{environment.default_hostname}/testinguser/blog/feed" }
  end

  should "add meta tag to rss feed on view post blog" do
    login_as_rails5(profile.identifier)
    blog = Blog.create!(name: "Blog", profile: profile)
    TextArticle.create!(name: "first post", parent: blog, profile: profile)
    get page_path(profile.identifier, page: ["blog", "first-post"])
    assert_tag tag: "link", attributes: { rel: "alternate", type: "application/rss+xml", title: "Blog", href: "http://#{environment.default_hostname}/testinguser/blog/feed" }
  end

  should "hit the article when viewed" do
    a = profile.articles.create!(name: "test article")
    get page_path(profile.identifier, page: [a.path]), headers: { 'HTTP_USER_AGENT': "SOME" }
    a.reload
    assert_equal 1, a.hits
  end

  should "render html for image when view" do
    file = UploadedFile.create!(uploaded_data: fixture_file_upload("/files/rails.png", "image/png"), profile: profile)
    get page_path(profile.identifier, page: file.path), params: { view: true }

    assert_response :success
    assert_template "view_page"
  end

  should "display download button to images in galleries that allow downloads" do
    login_as_rails5(profile.identifier)
    gallery = Gallery.create!(name: "gallery1", profile: profile, allow_download: true)
    image = UploadedFile.create!(profile: profile, parent: gallery, uploaded_data: fixture_file_upload("/files/other-pic.jpg", "image/jpg"))
    get page_path(profile.identifier, page: image.path), params: { view: true }
    assert_tag tag: "a", content: "Download image", attributes: { id: "download-image-id" }
  end

  should "not display download button to images in galleries that do not allow downloads" do
    login_as_rails5(profile.identifier)
    gallery = Gallery.create!(name: "gallery1", profile: profile, allow_download: false)
    image = UploadedFile.create!(profile: profile, parent: gallery, uploaded_data: fixture_file_upload("/files/other-pic.jpg", "image/jpg"))
    get page_path(profile.identifier, page: image.path), params: { view: true }
    !assert_tag tag: "a", content: "Download image", attributes: { id: "download-image-id" }
  end

  should "display 'Upload files' when create children of image gallery" do
    login_as_rails5(profile.identifier)
    f = Gallery.create!(name: "gallery", profile: profile)
    get page_path(profile.identifier, page: f.path), params: { toolbar: true }, xhr: true
    assert_tag tag: "a", content: "Upload files", attributes: { href: /parent_id=#{f.id}/ }
  end

  should "display 'New article' when showing folder child of image gallery" do
    login_as_rails5(profile.identifier)
    folder1 = Gallery.create!(name: "gallery1", profile: profile)
    folder1.children << folder2 = Folder.new(name: "gallery2", profile: profile)

    get page_path(profile.identifier, page: folder2.path), params: { toolbar: true }, xhr: true
    assert_tag tag: "a", content: "New article", attributes: { href: /parent_id=#{folder2.id}/ }
  end

  should "display 'Upload files' to image gallery when showing its children" do
    login_as_rails5(profile.identifier)
    folder = Gallery.create!(name: "gallery", profile: profile)
    file = UploadedFile.create!(profile: profile, parent: folder, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))
    get page_path(profile.identifier, page: file.path, view: true), params: { toolbar: true }, xhr: true

    assert_tag tag: "a", content: "Upload files", attributes: { href: /parent_id=#{folder.id}/ }
  end

  should "render slideshow template" do
    f = Folder.create!(name: "gallery", profile: profile)
    get page_path(profile.identifier, page: f.path), params: { slideshow: true }

    assert_template "slideshow"
  end

  should "display all images from profile in the slideshow" do
    @controller.stubs(:per_page).returns(1)
    folder = Gallery.create!(name: "gallery", profile: profile)

    image1 = UploadedFile.create!(profile: profile, parent: folder, uploaded_data: fixture_file_upload("/files/other-pic.jpg", "image/jpg"))
    image2 = UploadedFile.create!(profile: profile, parent: folder, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))

    get page_path(profile.identifier, page: folder.path), params: { slideshow: true }

    assert_equal 2, assigns(:images).size
  end

  should "not display private images in the slideshow for unauthorized people" do
    owner = create_user("owner").person
    unauthorized = create_user("unauthorized").person
    folder = Gallery.create!(name: "gallery", profile: owner)
    image1 = UploadedFile.create!(profile: owner, parent: folder,
                                  uploaded_data: fixture_file_upload("/files/other-pic.jpg", "image/jpg"), published: false, access: Entitlement::Levels.levels[:self])

    login_as_rails5("unauthorized")
    get page_path(owner.identifier, page: folder.path), params: { slideshow: true }
    assert_response :success
    assert_equal 0, assigns(:images).length
  end

  should "not display private images thumbnails for unauthorized people" do
    owner = create_user("owner").person
    unauthorized = create_user("unauthorized").person
    folder = Gallery.create!(name: "gallery", profile: owner)
    image1 = UploadedFile.create!(profile: owner, parent: folder, uploaded_data: fixture_file_upload("/files/other-pic.jpg", "image/jpg"), published: false, access: Entitlement::Levels.levels[:self])
    login_as_rails5("unauthorized")
    get page_path(owner.identifier, page: folder.path)
    assert_response :success
    assert_select ".image-gallery-item", 0
  end

  should "display original image in the slideshow if thumbnails were not processed" do
    @controller.stubs(:per_page).returns(1)
    folder = Gallery.create!(name: "gallery", profile: profile)

    image1 = UploadedFile.create!(profile: profile, parent: folder,
                                  uploaded_data: fixture_file_upload("/files/other-pic.jpg", "image/jpg"))
    UploadedFile.any_instance.stubs(:thumbnails_processed).returns(false)

    get page_path(profile.identifier, page: folder.path), params: { slideshow: true }

    assert_tag tag: "img", attributes: { src: /\/other-pic.jpg/ }
  end

  should "display thumbnail image in the slideshow if thumbnails were processed" do
    @controller.stubs(:per_page).returns(1)
    folder = Gallery.create!(name: "gallery", profile: profile)

    image1 = UploadedFile.create!(profile: profile, parent: folder, uploaded_data: fixture_file_upload("/files/other-pic.jpg", "image/jpg"))

    get page_path(profile.identifier, page: folder.path), params: { slideshow: true }

    assert_tag tag: "img", attributes: { src: /other-pic_display.jpg/ }
  end

  should "display original image in gallery if thumbnails were not processed" do
    @controller.stubs(:per_page).returns(1)
    folder = Gallery.create!(name: "gallery", profile: profile)

    image1 = UploadedFile.create!(profile: profile, parent: folder, uploaded_data: fixture_file_upload("/files/other-pic.jpg", "image/jpg"))
    UploadedFile.any_instance.stubs(:thumbnails_processed).returns(false)

    get page_path(profile.identifier, page: folder.path)

    assert_tag tag: "a", attributes: { class: "image", style: /background-image: url\(.*\/other-pic.jpg\)/ }
  end

  should "display thumbnail image in gallery if thumbnails were processed" do
    @controller.stubs(:per_page).returns(1)
    folder = Gallery.create!(name: "gallery", profile: profile)

    image1 = UploadedFile.create!(profile: profile, parent: folder, uploaded_data: fixture_file_upload("/files/other-pic.jpg", "image/jpg"))

    get page_path(profile.identifier, page: folder.path)

    assert_tag tag: "a", attributes: { class: "image", style: /background-image: url\(.*\/other-pic_thumb.jpg\)/ }
  end

  should "display source from article" do
    profile.articles << TextArticle.new(name: "Article one", profile: profile, source: "http://www.original-source.invalid")
    get page_path(profile.identifier, page: ["article-one"])
    assert_tag tag: "div", attributes: { id: "article-source" }, content: /http:\/\/www.original-source.invalid/
  end

  should "not display source if article has no source" do
    profile.articles << TextArticle.new(name: "Article one", profile: profile)
    get page_path(profile.identifier, page: ["article-one"])
    !assert_tag tag: "div", attributes: { id: "article-source" }
  end

  should "redirect to profile controller when there is no homepage" do
    profile.home_page.destroy
    get page_path(profile.identifier, page: [])
    assert_redirected_to controller: "profile", action: "index", profile: profile.identifier
  end

  should "display title of image on image gallery" do
    login_as_rails5(profile.identifier)
    folder = fast_create(Gallery, profile_id: profile.id)
    file = UploadedFile.create!(title: "my img title", profile: profile, parent: folder, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))

    get page_path(profile.identifier, page: folder.path)

    assert_tag tag: "li", attributes: { title: "my img title", class: "image-gallery-item" }, child: { tag: "span", content: "my img title" }
  end

  should "display link to new_article if profile is publisher" do
    c = Community.create!(name: "test_com")
    u = create_user_with_permission("test_user", "post_content", c)
    login_as_rails5 u.identifier
    a = create(Article, profile: c, name: "test-article",
                        author: profile, published: true)

    get page_path(c.identifier, page: a.path), params: { toolbar: true }, xhr: true

    assert_tag tag: "a", content: "New article"
  end

  should "display message if user was removed" do
    article = profile.articles.create(name: "comment test")
    to_be_removed = create_user("removed_user").person
    comment = article.comments.create(author: to_be_removed, title: "Test Comment", body: "My author does not exist =(")
    to_be_removed.destroy

    get page_path(profile.identifier, page: article.path)

    assert_tag tag: "a", attributes: { title: " (removed user)" }
  end

  should "show only first paragraph of blog posts if visualization_format is short" do
    login_as_rails5(profile.identifier)

    blog = Blog.create!(name: "A blog test", profile: profile, visualization_format: "short")

    blog.posts.to_a << TextArticle.create!(name: "first post", parent: blog, profile: profile, body: "<p>Content to be displayed.</p> Anything")

    get page_path(profile.identifier, page: blog.path)

    assert_tag tag: "div", attributes: { class: "short-post" }, content: /Content to be displayed./
    !assert_tag tag: "div", attributes: { class: "short-post" }, content: /Anything/
  end

  should "show only first paragraph with picture of posts if visualization_format is short+pic" do
    login_as_rails5(profile.identifier)

    blog = Blog.create!(name: "A blog test", profile: profile, visualization_format: "short+pic")

    blog.posts.to_a << TextArticle.create!(name: "first post", parent: blog, profile: profile, body: '<p>Content to be displayed.</p> <img src="pic.jpg">')

    get page_path(profile.identifier, page: blog.path)

    assert_select ".blog-post .post-pic" do |el|
      assert_match /background-image:url\(pic.jpg\)/, el.to_s
    end
  end

  should "display link to edit blog for allowed" do
    blog = fast_create(Blog, profile_id: profile.id, path: "blog")
    login_as_rails5(profile.identifier)
    get page_path(profile.identifier, page: blog.path), params: { toolbar: true }, xhr: true

    assert_tag tag: "ul",
               attributes: { class: "noosfero-dropdown-menu" },
               descendant: { tag: "a",
                             attributes: { href: "/myprofile/testinguser/cms/#{blog.id}/edit" },
                             descendant: { tag: "i",
                                           attributes: { class: "fa fa-edit" } } }
  end

  # Forum

  should "list unpublished forum posts to owner with a different class" do
    login_as_rails5("testinguser")
    forum = Forum.create!(name: "A forum test", profile: profile)
    forum.posts << TextArticle.create!(name: "Post", profile: profile,
                                       parent: forum,
                                       published: true,
                                       access: Entitlement::Levels.levels[:self])

    get page_path(profile.identifier, page: [forum.path])
    assert_tag tag: "tr", attributes: { class: /private/ }
  end

  should "not list unpublished forum posts to a not logged person" do
    forum = Forum.create!(name: "A forum test", profile: profile)
    forum.posts << TextArticle.create!(name: "Post", profile: profile, parent: forum, published: false, access: Entitlement::Levels.levels[:self])

    get page_path(profile.identifier, page: [forum.path])
    !assert_tag tag: "a", content: "Post"
  end

  should "display pagination links of forum" do
    forum = Forum.create!(name: "A forum test", profile: profile, posts_per_page: 5)
    for n in 1..10
      forum.posts << TextArticle.create!(name: "Post #{n}", profile: profile, parent: forum)
    end
    assert_equal 10, forum.posts.size

    get page_path(profile.identifier, page: [forum.path])
    assert_tag tag: "a", attributes: { href: "/#{profile.identifier}/#{forum.path}?npage=2", rel: "next" }
  end

  should "display first page of forum posts" do
    forum = Forum.create!(name: "My forum", profile: profile, posts_per_page: 5)
    for n in 1..10
      art = TextArticle.create!(name: "Post #{n}", profile: profile, parent: forum)
      art.updated_at = (10 - n).days.ago
      art.stubs(:record_timestamps).returns(false)
      art.save!
    end
    assert_equal 10, forum.posts.size

    get page_path(profile.identifier, page: [forum.path])
    for n in 1..5
      !assert_tag tag: "a", content: "Post #{n}", parent: { tag: "td", parent: { tag: "tr", attributes: { class: /forum-post/ } } }
    end
    for n in 6..10
      assert_tag tag: "a", content: "Post #{n}", parent: { tag: "td", parent: { tag: "tr", attributes: { class: /forum-post/ } } }
    end
  end

  should "display others pages of forum posts" do
    forum = Forum.create!(name: "My forum", profile: profile, posts_per_page: 5)
    now = Time.now
    for n in 1..10
      Time.stubs(:now).returns(now - 10.days + n.days)
      forum.children << art = TextArticle.create!(name: "Post #{n}", profile: profile, parent: forum)
    end
    assert_equal 10, forum.posts.size

    get page_path(profile.identifier, page: [forum.path]), params: { npage: 2 }
    for n in 1..5
      assert_tag tag: "a", content: "Post #{n}", parent: { tag: "td", parent: { tag: "tr", attributes: { class: /forum-post/ } } }
    end
    for n in 6..10
      !assert_tag tag: "a", content: "Post #{n}", parent: { tag: "td", parent: { tag: "tr", attributes: { class: /forum-post/ } } }
    end
  end

  should "set year and month filter from URL params for forum" do
    forum = Forum.create!(name: "forum", profile: profile)
    profile.articles << forum

    past_post = create(TextArticle, name: "past post", profile: profile, parent: forum, published_at: forum.created_at - 1.year)
    current_post = TextArticle.create!(name: "current post", profile: profile, parent: forum)
    forum.children << past_post
    forum.children << current_post

    year, month = forum.created_at.year.to_s, "%02d" % forum.created_at.month

    get page_path(profile.identifier, page: [profile.forum.path], year: year), params: { month: month }

    !assert_tag tag: "a", content: past_post.title
    assert_tag tag: "a", content: current_post.title
  end

  should "display 'New discussion topic' when create children of forum" do
    login_as_rails5(profile.identifier)
    a = Forum.create!(name: "article folder", profile: profile)
    Article.stubs(:short_description).returns("bli")
    get page_path(profile.identifier, page: [a.path]), params: { toolbar: true }, xhr: true
    assert_tag tag: "a", content: "New discussion topic"
  end

  should "display same label for new article button of forum parent" do
    login_as_rails5(profile.identifier)
    a = Forum.create!(name: "article folder", profile: profile)
    Article.stubs(:short_description).returns("bli")
    t = TextArticle.create!(name: "first post", parent: a, profile: profile)
    get page_path(profile.identifier, page: [t.path]), params: { toolbar: true }, xhr: true
    assert_tag tag: "a", content: "New discussion topic"
  end

  should "display icon-edit button to author topic" do
    community = fast_create(Community)
    admin = fast_create(Person)
    community.add_member(admin)
    author = create_user("author").person
    community.add_member(author)

    forum = Forum.create(profile: community, name: "Forum test", body: "Forum test")
    post = fast_create(TextArticle, name: "First post", profile_id: community.id, parent_id: forum.id, author_id: author.id)

    login_as_rails5(author.identifier)
    get page_path(community.identifier, page: post.path.split("/"))

    assert_tag tag: "ul",
               attributes: { class: "noosfero-dropdown-menu" },
               descendant: { tag: "a",
                             descendant: { tag: "i",
                                           attributes: { class: "fa fa-edit" } } }
  end

  should "display icon-delete button to author topic" do
    community = fast_create(Community)
    admin = fast_create(Person)
    community.add_member(admin)
    author = create_user("author").person
    community.add_member(author)

    forum = Forum.create(profile: community, name: "Forum test", body: "Forum test")
    post = fast_create(TextArticle, name: "First post", profile_id: community.id,
                                    parent_id: forum.id, author_id: author.id)

    login_as_rails5(author.identifier)
    get page_path(community.identifier, page: post.path.split("/"))

    assert_tag tag: "ul",
               attributes: { class: "noosfero-dropdown-menu" },
               descendant: { tag: "a",
                             descendant: { tag: "i",
                                           attributes: { class: "fa fa-trash-alt" } } }
  end

  should "add meta tag to rss feed on view forum" do
    login_as_rails5(profile.identifier)
    profile.articles << Forum.new(name: "Forum", profile: profile)
    get page_path(profile.identifier, page: ["forum"])
    assert_tag tag: "link", attributes: { rel: "alternate",
                                          type: "application/rss+xml",
                                          title: "Forum",
                                          href: "http://#{environment.default_hostname}/testinguser/forum/feed" }
  end

  should "add meta tag to rss feed on view post forum" do
    login_as_rails5(profile.identifier)
    profile.articles << Forum.new(name: "Forum", profile: profile)
    profile.forum.posts << TextArticle.new(name: "first post", parent: profile.forum, profile: profile)
    get page_path(profile.identifier, page: ["forum", "first-post"])
    assert_tag tag: "link", attributes: { rel: "alternate", type: "application/rss+xml", title: "Forum", href: "http://#{environment.default_hostname}/testinguser/forum/feed" }
  end

  should "not display 'Upload files' when viewing forum" do
    login_as_rails5(profile.identifier)
    b = Forum.create!(name: "article folder", profile: profile)
    get page_path(profile.identifier, page: b.path), params: { toolbar: true }, xhr: true
    !assert_tag tag: "a", content: "Upload files", attributes: { href: /parent_id=#{b.id}/ }
  end

  should "not display 'Upload files' when viewing post from a forum" do
    login_as_rails5(profile.identifier)
    b = Forum.create!(name: "article folder", profile: profile)
    forum_post = TextArticle.create!(name: "children-article", profile: profile, parent: b)
    get page_path(profile.identifier, page: forum_post.path), params: { toolbar: true }, xhr: true
    !assert_tag tag: "a", content: "Upload files", attributes: { href: /parent_id=#{b.id}/ }
  end

  should "display link to edit forum for allowed" do
    forum = fast_create(Forum, profile_id: profile.id, path: "forum")
    login_as_rails5(profile.identifier)
    get page_path(profile.identifier, page: forum.path), params: { toolbar: true }, xhr: true

    assert_tag tag: "ul",
               attributes: { class: "noosfero-dropdown-menu" },
               descendant: { tag: "a",
                             attributes: { href: "/myprofile/testinguser/cms/#{forum.id}/edit" },
                             descendant: { tag: "i",
                                           attributes: { class: "fa fa-edit" } } }
  end

  should "display add translation link if article is translatable" do
    environment.languages = ["en"]
    environment.save
    login_as_rails5 @profile.identifier
    textile = fast_create(TextArticle, profile_id: @profile.id, path: "textile", language: "en")
    get page_path(@profile.identifier, page: textile.path), params: { toolbar: true }, xhr: true
    assert_tag :a, attributes: { href: "/myprofile/#{profile.identifier}/cms/new?article%5Btranslation_of_id%5D=#{textile.id}&type=#{TextArticle}" }
  end

  should "not display add translation link if article is not translatable" do
    login_as_rails5 @profile.identifier
    blog = fast_create(Blog, profile_id: @profile.id, path: "blog")
    get page_path(@profile.identifier, page: blog.path), params: { toolbar: true }, xhr: true
    !assert_tag :a, attributes: { content: "Add translation", class: /icon-locale/ }
  end

  should "not display add translation link if article hasnt a language defined" do
    login_as_rails5 @profile.identifier
    textile = fast_create(TextArticle, profile_id: @profile.id, path: "textile")
    get page_path(@profile.identifier, page: textile.path), params: { toolbar: true }, xhr: true
    !assert_tag :a, attributes: { content: "Add translation", class: /icon-locale/ }
  end

  should "display translations link if article has translations" do
    login_as_rails5 @profile.identifier
    textile     = fast_create(TextArticle, profile_id: @profile.id, path: "textile", language: "en")
    translation = fast_create(TextArticle, profile_id: @profile.id, path: "translation", language: "es", translation_of_id: textile)
    get page_path(@profile.identifier, page: textile.path), params: { toolbar: true }, xhr: true
    assert_tag :a, attributes: { class: /article-translations-menu/, onmouseover: /toggleSubmenu/ }
  end

  should "not be redirected if already in translation" do
    en_article = fast_create(TextArticle, profile_id: @profile.id, path: "en_article", language: "en")
    es_article = fast_create(TextArticle, profile_id: @profile.id, path: "es_article", language: "es", translation_of_id: en_article)
    FastGettext.stubs(:locale).returns("es")
    get page_path(@profile.identifier, page: es_article.path), headers: { "HTTP_REFERER" => "http://localhost:3000/#{@profile.identifier}/#{es_article.path}" }
    assert_response :success
    assert_equal es_article, assigns(:page)
  end

  should "not be redirected if article does not have a language" do
    FastGettext.stubs(:locale).returns("es")
    article = fast_create(TextArticle, profile_id: @profile.id, path: "article")
    get page_path(@profile.identifier, page: article.path)
    assert_response :success
    assert_equal article, assigns(:page)
  end

  #  should 'not be redirected if http_referer is a translation' do
  #    en_article = fast_create(TextArticle, :profile_id => @profile.id, :path => 'en_article', :language => 'en')
  #    es_article = fast_create(TextArticle, :profile_id => @profile.id, :path => 'es_article', :language => 'es', :translation_of_id => en_article)
  #    FastGettext.stubs(:locale).returns('es')
  #    @profile.redirect_l10n = true
  #    @profile.save
  #    get page_path(@profile.identifier, :page => es_article.path), headers: { "HTTP_REFERER" => "http://localhost:3000/#{@profile.identifier}/#{es_article.path}"}
  #    assert_response :success
  #    assert_equal en_article, assigns(:page)
  #  end

  should "not be redirected to transition if came from edit" do
    en_article = fast_create(TextArticle, profile_id: @profile.id, path: "en_article", language: "en")
    es_article = fast_create(TextArticle, profile_id: @profile.id, path: "es_article", language: "es", translation_of_id: en_article)
    FastGettext.stubs(:locale).returns("es")
    get page_path(@profile.identifier, page: es_article.path), headers: { "HTTP_REFERER" => "http://localhost/myprofile/#{@profile.identifier}/cms/#{en_article.id}/edit" }
    assert_response :success
    assert_equal es_article, assigns(:page)
  end

  should "not be redirected to transition if came from new" do
    en_article = fast_create(TextArticle, profile_id: @profile.id, path: "en_article", language: "en")
    es_article = fast_create(TextArticle, profile_id: @profile.id, path: "es_article", language: "es", translation_of_id: en_article)
    FastGettext.stubs(:locale).returns("es")
    get page_path(@profile.identifier, page: es_article.path), headers: { "HTTP_REFERER" => "http://localhost/myprofile/#{@profile.identifier}/cms/new" }
    assert_response :success
    assert_equal es_article, assigns(:page)
  end

  should "replace article for his translation at blog listing if blog option is enabled" do
    FastGettext.stubs(:locale).returns("es")
    blog = fast_create(Blog, profile_id: profile.id, path: "blog")
    blog.display_posts_in_current_language = true
    blog.save
    en_article = fast_create(TextArticle, profile_id: @profile.id, path: "en_article", language: "en", parent_id: blog.id)
    es_article = fast_create(TextArticle, profile_id: @profile.id, path: "es_article", language: "es", parent_id: blog.id, translation_of_id: en_article)

    get page_path(@profile.identifier, page: blog.path)
    assert_tag :div, attributes: { id: "post-#{es_article.id}" }
    !assert_tag :div, attributes: { id: "post-#{en_article.id}" }
  end

  should "not display article at blog listing if blog option is enabled and there is no translation for the language" do
    FastGettext.stubs(:locale).returns("pt")
    blog = fast_create(Blog, profile_id: profile.id, path: "blog")
    blog.display_posts_in_current_language = true
    blog.save
    en_article = fast_create(TextArticle, profile_id: @profile.id, path: "en_article", language: "en", parent_id: blog.id)
    es_article = fast_create(TextArticle, profile_id: @profile.id, path: "es_article", language: "es", parent_id: blog.id, translation_of_id: en_article)
    pt_article = fast_create(TextArticle, profile_id: @profile.id, path: "es_article", language: "pt", parent_id: blog.id, translation_of_id: en_article)

    en_article2 = fast_create(TextArticle, profile_id: @profile.id, path: "en_article", language: "en", parent_id: blog.id)
    es_article2 = fast_create(TextArticle, profile_id: @profile.id, path: "es_article", language: "es", parent_id: blog.id, translation_of_id: en_article2)

    get page_path(@profile.identifier, page: blog.path)

    assert_equal [pt_article], assigns(:posts)
  end

  should "list all posts at blog listing if blog option is disabled" do
    FastGettext.stubs(:locale).returns("es")
    blog = Blog.create!(name: "A blog test", profile: profile, display_posts_in_current_language: false)
    blog.posts.to_a << es_post = TextArticle.create!(name: "Spanish Post", profile: profile, parent: blog, language: "es")
    blog.posts.to_a << en_post = TextArticle.create!(name: "English Post", profile: profile, parent: blog, language: "en", translation_of_id: es_post.id)
    get page_path(profile.identifier, page: [blog.path])
    assert_equal 2, assigns(:posts).size
    assert_tag :div, attributes: { id: "post-#{es_post.id}" }
    assert_tag :div, attributes: { id: "post-#{en_post.id}" }
  end

  should "display only native translations at blog listing if blog option is enabled" do
    FastGettext.stubs(:locale).returns("es")
    blog = fast_create(Blog, profile_id: profile.id, path: "blog")
    blog.display_posts_in_current_language = true
    blog.save!
    en_article = fast_create(TextArticle, profile_id: @profile.id, path: "en_article", language: "en", parent_id: blog.id)
    es_article = fast_create(TextArticle, profile_id: @profile.id, path: "es_article", language: "es", parent_id: blog.id, translation_of_id: en_article)
    blog.posts = [en_article, es_article]

    get page_path(@profile.identifier, page: blog.path)
    assert_equal [es_article], assigns(:posts)
  end

  should "display reply to comment button if authenticated" do
    profile = create_user("testuser").person
    article = profile.articles.build(name: "test")
    article.save!
    Comment.destroy_all
    comment = article.comments.create!(author: profile, title: "a comment", body: "lalala")
    login_as_rails5 "testuser"
    get page_path("testuser", page: ["test"])
    assert_tag tag: "a", attributes: { class: "reply-comment-link" }
  end

  should "display reply to comment button if not authenticated" do
    profile = create_user("testuser").person
    article = profile.articles.build(name: "test")
    article.save!
    comment = article.comments.build(author: profile, title: "a comment", body: "lalala")
    comment.save!
    get page_path("testuser", page: ["test"])
    assert_tag tag: "a", attributes: { class: "reply-comment-link" }
  end

  should "display replies if comment has replies" do
    profile = create_user("testuser").person
    article = profile.articles.build(name: "test")
    article.save!
    comment1 = article.comments.build(author: profile, title: "a comment", body: "lalala")
    comment1.save!
    comment2 = article.comments.build(author: profile, title: "a comment", body: "replying to lalala", reply_of_id: comment1.id)
    comment2.save!
    get page_path("testuser", page: ["test"])
    assert_tag tag: "ul", attributes: { class: "comment-replies" }
  end

  should "not display replies if comment does not have replies" do
    profile = create_user("testuser").person
    article = profile.articles.build(name: "test")
    article.save!
    comment = article.comments.build(author: profile, title: "a comment", body: "lalala")
    comment.save!
    get page_path("testuser", page: ["test"])
    !assert_tag tag: "ul", attributes: { class: "comment-replies" }
  end

  should "add an zero width space every 4 caracters of comment urls" do
    url = "www.an.url.to.be.splited.com"
    a = fast_create(TextArticle, profile_id: @profile.id, language: "en")
    c = a.comments.create!(author: @profile, title: "An url", body: url)
    get page_path(@profile.identifier, page: a.path)
    assert_tag :a, attributes: { href: "http://" + url }, content: url.scan(/.{4}/).join("&#x200B;")
  end

  should "not show a post comment button on top if there is only one comment" do
    profile = create_user("testuser").person
    article = profile.articles.build(name: "test")
    Comment.destroy_all
    article.save!
    comment = article.comments.build(author: profile, title: "hi", body: "hello")
    comment.save!
    get page_path("testuser", page: ["test"])
    !assert_tag tag: "a", attributes: { id: "top-post-comment-button" }
  end

  should "not show a post comment button on top if there are no comments" do
    profile = create_user("testuser").person
    article = profile.articles.build(name: "test")
    Comment.destroy_all
    article.save!
    get page_path("testuser", page: ["test"])
    !assert_tag tag: "a", attributes: { id: "top-post-comment-button" }
  end

  should "not show a post comment button on top if there are one comment and one reply" do
    profile = create_user("testuser").person
    article = profile.articles.build(name: "test")
    Comment.destroy_all
    article.save!
    comment1 = article.comments.build(author: profile, title: "hi", body: "hello")
    comment1.save!
    comment2 = article.comments.build(author: profile, title: "hi", body: "hello", reply_of_id: comment1.id)
    comment2.save!
    get page_path("testuser", page: ["test"])
    !assert_tag tag: "a", attributes: { id: "top-post-comment-button" }
  end

  should "suggest article link displayed into article-actions div" do
    community = fast_create(Community)
    blog = fast_create(Blog, profile_id: community.id, path: "blog")
    get page_path(community.identifier, page: ["blog"]), params: { toolbar: true }, xhr: true
    assert_tag tag: "a", attributes: { id: "suggest-article-link" }
  end

  should "render toolbar when it is an ajax request" do
    community = fast_create(Community)
    blog = fast_create(Blog, profile_id: community.id, path: "blog")
    get page_path(community.identifier, page: ["blog"]), params: { toolbar: true }, xhr: true
    assert_tag tag: "div", attributes: { id: "article-header" }
  end

  should "add class to body tag if is on profile homepage" do
    profile = fast_create(Profile)
    blog = fast_create(Blog, profile_id: profile.id, path: "blog")
    profile.home_page = blog
    profile.save
    get page_path(profile.identifier, page: ["blog"])
    assert_tag tag: "body", attributes: { class: /profile-homepage/ }
  end

  should "not add class to body tag if is not on profile homepage" do
    profile = fast_create(Profile)
    blog = fast_create(Blog, profile_id: profile.id, path: "blog")
    get page_path(profile.identifier, page: ["blog"])
    !assert_tag tag: "body", attributes: { class: /profile-homepage/ }
  end

  should "not display article actions button if any plugins says so" do
    class Plugin1 < Noosfero::Plugin
      def content_remove_edit(content); true; end
    end
    class Plugin2 < Noosfero::Plugin
      def content_remove_edit(content); false; end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    login_as_rails5("testinguser")
    get page_path("testinguser", page: []), params: { toolbar: true }, xhr: true
    !assert_tag tag: "ul", attributes: { class: "noosfero-dropdown-menu" }, descendant: { tag: "a", attributes: { href: "/myprofile/testinguser/cms/#{profile.home_page.id}/edit" } }
  end

  should "expire article actions button if any plugins says so" do
    class Plugin1 < Noosfero::Plugin
      def content_expire_edit(content); "This button is expired."; end

      def content_expire_clone(content); "This button is expired."; end
    end
    class Plugin2 < Noosfero::Plugin
      def content_expire_edit(content); nil; end

      def content_expire_clone(content); nil; end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    environment.enable_plugin(Plugin1.name)
    environment.enable_plugin(Plugin2.name)

    login_as_rails5("testinguser")
    get page_path("testinguser", page: []), params: { toolbar: true }, xhr: true
    assert_tag tag: "ul", attributes: { class: "noosfero-dropdown-menu" }, descendant: { tag: "a", attributes: { title: "This button is expired." } }
  end

  should "not display comments marked as spam" do
    article = fast_create(Article, profile_id: profile.id)
    ham = fast_create(Comment, source_id: article.id, source_type: "Article", title: "some content")
    spam = fast_create(Comment, source_id: article.id, source_type: "Article", spam: true, title: "this is a spam")

    get page_path(profile.identifier, page: article.path.split("/"))
    !assert_tag tag: "h4", content: /spam/
  end

  should "add extra content on comment form from plugins" do
    class Plugin1 < Noosfero::Plugin
      def comment_form_extra_contents(args)
        proc {
          hidden_field_tag("comment[some_field_id]", 1)
        }
      end
    end
    class Plugin2 < Noosfero::Plugin
      def comment_form_extra_contents(args)
        proc {
          hidden_field_tag("comment[another_field_id]", 1)
        }
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    Environment.default.enable_plugin(Plugin1.name)
    Environment.default.enable_plugin(Plugin2.name)

    page = profile.articles.create!(name: "myarticle", body: "the body of the text")

    get page_path(profile.identifier, page: ["myarticle"])

    assert_tag tag: "input", attributes: { name: "comment[some_field_id]", type: "hidden" }
    assert_tag tag: "input", attributes: { name: "comment[another_field_id]", type: "hidden" }
  end

  should "filter comments with scope defined by the plugins" do
    class Plugin1 < Noosfero::Plugin
      def unavailable_comments(scope)
        scope.where(user_agent: "Jack")
      end
    end

    class Plugin2 < Noosfero::Plugin
      def unavailable_comments(scope)
        scope.where(referrer: "kernel.org")
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    Environment.default.enable_plugin(Plugin1)
    Environment.default.enable_plugin(Plugin2)
    profile = fast_create(Profile)
    article = fast_create(Article, profile_id: profile.id)
    c1 = fast_create(Comment, source_id: article.id, user_agent: "Jack", referrer: "kernel.org")
    c2 = fast_create(Comment, source_id: article.id, user_agent: "Rose", referrer: "kernel.org")
    c3 = fast_create(Comment, source_id: article.id, user_agent: "Jack", referrer: "google.com")

    get page_path(profile.identifier, page: [article.path])

    assert_includes assigns(:comments), c1
    assert_not_includes assigns(:comments), c2
    assert_not_includes assigns(:comments), c3
  end

  should "not escape acceptable HTML in list of blog posts" do
    login_as_rails5("testinguser")
    blog = Blog.create!(name: "A blog test", profile: profile)
    blog.posts.to_a << TextArticle.create!(
      name: "Post",
      profile: profile,
      parent: blog,
      published: true,
      body: "<p>This is a <strong>bold</strong> statement right there!</p>"
    )

    get page_path(profile.identifier, page: [blog.path])
    assert_tag tag: "strong", content: /bold/
  end

  should "add extra content on article header from plugins" do
    class Plugin1 < Noosfero::Plugin
      def article_header_extra_contents(args)
        proc {
          content_tag("div", "", class: "plugin1")
        }
      end
    end
    class Plugin2 < Noosfero::Plugin
      def article_header_extra_contents(args)
        proc {
          content_tag("div", "", class: "plugin2")
        }
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    Environment.default.enable_plugin(Plugin1.name)
    Environment.default.enable_plugin(Plugin2.name)

    page = profile.articles.create!(name: "myarticle", body: "the body of the text")

    get page_path(profile.identifier, page: ["myarticle"]), params: { toolbar: true }, xhr: true

    assert_tag tag: "div", attributes: { class: "plugin1" }
    assert_tag tag: "div", attributes: { class: "plugin2" }
  end

  should "display link to download of non-recognized file types on its page" do
    file = UploadedFile.create!(uploaded_data: fixture_file_upload("/files/test.txt", "bin/unknown"), profile: profile)
    get page_path(profile.identifier, page: file.url[:page])
    assert_match /#{file.public_filename}/, @response.body
  end

  should "not count hit from bots" do
    article = fast_create(Article, profile_id: profile.id)
    assert_no_difference "article.hits" do
      get page_path(profile.identifier, page: article.path.split("/")), headers: { 'HTTP_USER_AGENT': "bot" }
      get page_path(profile.identifier, page: article.path.split("/")), headers: { 'HTTP_USER_AGENT': "spider" }
      get page_path(profile.identifier, page: article.path.split("/")), headers: { 'HTTP_USER_AGENT': "crawler" }
      get page_path(profile.identifier, page: article.path.split("/")), headers: { 'HTTP_USER_AGENT': "(http://some-crawler.com)" }
      article.reload
    end
  end

  should "manage private article visualization" do
    community = Community.create(name: "test-community")
    community.add_member(@profile)
    community.save!

    blog = community.articles.find_by(name: "Blog")

    article = TextArticle.create(name: "Article to be shared with images",
                                 body: "This article should be shared with all social networks",
                                 profile: community,
                                 published: true,
                                 access: Entitlement::Levels.levels[:related])
    article.parent = blog
    article.save!

    otheruser = create_user("otheruser").person
    community.add_member(otheruser)
    login_as_rails5(otheruser.identifier)

    get page_path(community.identifier, "page" => "blog")

    assert_response :success
    assert_tag tag: "h1", attributes: { class: /title/ }, content: article.name

    article.access = Entitlement::Levels.levels[:self]
    article.save!

    get page_path(community.identifier, "page" => "blog")

    !assert_tag tag: "h1", attributes: { class: /title/ }, content: article.name
  end

  should "add extra toolbar actions on article from plugins" do
    class Plugin1 < Noosfero::Plugin
      def article_extra_toolbar_buttons(article)
        { title: "some_title1", icon: "my-icon", url: {} }
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name])

    Environment.default.enable_plugin(Plugin1.name)

    page = profile.articles.create!(name: "myarticle", body: "the body of the text")

    get page_path(profile.identifier, page: ["myarticle"])

    assert_tag tag: "ul",
               attributes: { class: "noosfero-dropdown-menu" },
               descendant: { tag: "a",
                             attributes: { title: "some_title1" },
                             descendant: { tag: "i",
                                           attributes: { class: "fa fa-my-icon" } } }
  end

  should "add more than one extra toolbar actions on article from plugins" do
    class Plugin1 < Noosfero::Plugin
      def article_extra_toolbar_buttons(article)
        { title: "some_title1", icon: "my-icon-1", url: {} }
      end
    end
    class Plugin2 < Noosfero::Plugin
      def article_extra_toolbar_buttons(article)
        { title: "some_title2", icon: "my-icon-2", url: {} }
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name, Plugin2.name])

    Environment.default.enable_plugin(Plugin1.name)
    Environment.default.enable_plugin(Plugin2.name)

    page = profile.articles.create!(name: "myarticle", body: "the body of the text")

    get page_path(profile.identifier, page: ["myarticle"])
    assert_tag tag: "ul",
               attributes: { class: "noosfero-dropdown-menu" },
               descendant: { tag: "a",
                             attributes: { title: "some_title1" },
                             descendant: { tag: "i",
                                           attributes: { class: "fa fa-my-icon-1" } } }
    assert_tag tag: "ul",
               attributes: { class: "noosfero-dropdown-menu" },
               descendant: { tag: "a",
                             attributes: { title: "some_title2" },
                             descendant: { tag: "i",
                                           attributes: { class: "fa fa-my-icon-2" } } }
  end

  should "add icon attribute in extra toolbar actions on article from plugins" do
    class Plugin1 < Noosfero::Plugin
      def article_extra_toolbar_buttons(article)
        { title: "some_title", icon: "my-icon", url: {} }
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name])

    Environment.default.enable_plugin(Plugin1.name)

    page = profile.articles.create!(name: "myarticle", body: "the body of the text")

    get page_path(profile.identifier, page: ["myarticle"])
    assert_tag tag: "ul",
               attributes: { class: "noosfero-dropdown-menu" },
               descendant: { tag: "a",
                             attributes: { title: "some_title" },
                             descendant: { tag: "i",
                                           attributes: { class: "fa fa-my-icon" } } }
  end

  should "add url attribute in extra toolbar actions on article from plugins" do
    class Plugin1 < Noosfero::Plugin
      def article_extra_toolbar_buttons(article)
        { title: "some_title", icon: "some_icon", url: "/someurl" }
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name])

    Environment.default.enable_plugin(Plugin1.name)

    page = profile.articles.create!(name: "myarticle", body: "the body of the text")

    get page_path(profile.identifier, page: ["myarticle"])
    assert_tag tag: "ul",
               attributes: { class: "noosfero-dropdown-menu" },
               descendant: { tag: "a",
                             attributes: { title: "some_title",
                                           href: "/someurl" } }
  end

  should "use context method in extra toolbar actions on article from plugins" do
    class Plugin1 < Noosfero::Plugin
      def article_extra_toolbar_buttons(article)
        if profile.name == "Special"
          { title: "another_title", icon: "another_icon", url: "/anotherurl" }
        else
          { title: "some_title", icon: "some_icon", url: "/someurl" }
        end
       end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.name])

    Environment.default.enable_plugin(Plugin1.name)

    page = profile.articles.create!(name: "myarticle", body: "the body of the text")

    profile.name = "Special"
    profile.save
    login_as_rails5(profile.identifier)
    get page_path(profile.identifier, page: ["myarticle"])
    assert_tag tag: "ul",
               attributes: { class: "noosfero-dropdown-menu" },
               descendant: { tag: "a",
                             attributes: { title: "another_title",
                                           href: "/anotherurl" } }
  end

  should "show lead,image and title in compact blog visualization" do
    community = Community.create(name: "test-community")
    community.add_member(@profile)
    community.save!

    blog = community.articles.find_by(name: "Blog")
    blog.visualization_format = "compact"
    blog.save!

    article = TextArticle.create(name: "Article to be shared with images",
                                 body: "This article should be shared with all social networks",
                                 profile: @profile,
                                 published: true,
                                 access: Entitlement::Levels.levels[:self],
                                 abstract: "teste teste teste",
                                 show_to_followers: true,
                                 image_builder: { uploaded_data: fixture_file_upload("/files/rails.png", "image/png") })
    article.parent = blog
    article.save!

    login_as_rails5(@profile.identifier)

    get page_path(community.identifier, "page" => "blog")

    assert_tag tag: "div", attributes: { class: "article-compact-image" }
    assert_tag tag: "div", attributes: { class: "article-compact-abstract-with-image" }
  end

  # FIXME see the way to test with cookies
  #  should 'not count a visit twice for the same user' do
  #    profile = create_user('someone').person
  #    login_as_rails5(@profile.identifier)
  #    page = profile.articles.build(:name => 'myarticle', :body => 'the body of the text')
  #    page.save!
  #
  #    get page_path(profile.identifier, :page => 'myarticle'), headers: {'HTTP_USER_AGENT': 'SOME'}
  #    page.reload
  #    assert_equal 1, page.hits
  #
  #    get page_path(profile.identifier, :page => 'myarticle'), headers: {'HTTP_USER_AGENT': 'SOME'}
  #    page.reload
  #    assert_equal 1, page.hits
  #  end

  # FIXME see the way to test with cookies
  #  should 'not count a visit twice for unlogged users' do
  #     logout
  #    my_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
  #    my_cookies.signed[:token] = '7e5201169ef160e31058d2a1976a5552'
  #
  #    cookies[:token] = my_cookies[:token]
  #     profile = create_user('someone').person
  #     page = profile.articles.build(:name => 'myarticle', :body => 'the body of the text')
  #     page.save!
  #
  #     get page_path(profile.identifier, :page => 'myarticle'), headers: {'HTTP_USER_AGENT': 'SOME', "HTTP_COOKIE" => "legal_accepted=yes; cookie2=value2;"}
  #     page.reload
  #     assert_equal 1, page.hits
  #
  #     get page_path(profile.identifier, :page => 'myarticle'), headers: {'HTTP_USER_AGENT': 'SOME', "HTTP_COOKIE" => "legal_accepted=yes; cookie2=value2;"}
  #     page.reload
  #     assert_equal 1, page.hits
  #  end

  should "show blog image only inside blog cover" do
    blog = create(Blog, profile_id: profile.id, name: "testblog", image_builder: { uploaded_data: fixture_file_upload("/files/rails.png", "image/png") })
    blog.save!
    get page_path(profile.identifier, page: [blog.path])

    assert_select ".blog-cover > img", 1
    assert_select ".article-body-img > img", 0
  end

  should "render follow article button in another domain" do
    d = Domain.new
    d.name = "theresourcebasedeconomy.com"
    d.save!
    profile = fast_create(Community)
    profile.domains << d

    page = profile.articles.build(name: "myarticle", body: "the body of the text")
    page.save!

    host! "theresourcebasedeconomy.com"
    login_as_rails5(create_user.login)

    get page_path(profile.identifier, page: "myarticle")

    assert_equal profile, assigns(:profile)
    assert_tag tag: "a", attributes: { "title" => "Follow" }
  end

  should "display only public custom fields" do
    page = profile.articles.build(name: "test")
    page.metadata["custom_fields"] = {
      "field1" => { "name" => "field1", "value" => "10", "type" => "text", "public" => "1" },
      "field2" => { "name" => "field2", "value" => "0", "type" => "boolean", "public" => "0" }
    }
    page.save!

    get page_path(profile.identifier, page: ["test"])
    assert_match /field1/i, @response.body
    assert_no_match /field2/i, @response.body
  end

  should "display private custom fields for authorized users" do
    page = profile.articles.build(name: "test")
    page.metadata["custom_fields"] = {
      "field1" => { "name" => "field1", "value" => "10", "type" => "text", "public" => "1" },
      "field2" => { "name" => "field2", "value" => "0", "type" => "boolean", "public" => "0" }
    }
    page.save!

    friend = create_user.person
    profile.add_friend(friend)
    login_as_rails5 friend.identifier

    get page_path(profile.identifier, page: ["test"])
    assert_match /field1/i, @response.body
    assert_match /field2/i, @response.body
  end
end
