require_relative "../test_helper"

class ContentViewerHelperTest < ActionView::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  include ContentViewerHelper
  include DatesHelper
  include ApplicationHelper

  def setup
    @profile = create_user("blog_helper_test").person
  end
  attr :profile

  should "display published-at for blog posts" do
    blog = fast_create(Blog, name: "Blog test", profile_id: profile.id)
    post = create(TextArticle, name: "post test", profile: profile, parent: blog)
    result = article_title(post)
    assert_tag_in_string result, tag: "span", content: show_time(post.published_at)
  end

  # TODO: non published article test.
  # should 'display privacy warning only for not published articles' do
  #  blog = fast_create(Blog, :name => 'Blog test', :profile_id => profile.id)
  #  post1 = create(TextArticle, :name => 'first post',
  #                 :profile => profile,
  #                 :parent => blog,
  #                 :published => true)
  #  post2 = create(TextArticle, :name => 'second post', :profile => profile, :parent => blog, :published => false)

  #  assert_no_tag_in_string article_title(post1),
  #    :tag => 'div', :attributes => { :class => 'private aler-text' }
  #  assert_tag_in_string article_title(post2),
  #    :tag => 'div', :attributes => { :class => 'private alert-text' }
  # end

  should "display published-at for forum posts" do
    forum = fast_create(Forum, name: "Forum test", profile_id: profile.id)
    post = TextArticle.create!(name: "post test", profile: profile, parent: forum)
    result = article_title(post)
    assert_tag_in_string result, tag: "span", content: show_time(post.published_at)
  end

  should "not display published-at for non-blog and non-forum posts" do
    article = create(TextArticle, name: "article for test", profile: profile)
    result = article_title(article)
    assert_no_match /<span class="date">#{show_date(article.published_at)}<\/span><span class="author">, by .*#{profile.identifier}/, result
  end

  should "create link on title of blog posts" do
    blog = fast_create(Blog, name: "Blog test", profile_id: profile.id)
    post = fast_create(TextArticle, name: "post test", profile_id: profile.id, parent_id: blog.id)
    assert post.belongs_to_blog?
    result = article_title(post)
    assert_tag_in_string result, tag: "h1", child: { tag: "a", content: "post test", attributes: { href: /my-article-\d+/ } }
  end

  should "not create link on title if pass no_link option" do
    blog = fast_create(Blog, name: "Blog test", profile_id: profile.id)
    post = fast_create(TextArticle, name: "post test", profile_id: profile.id, parent_id: blog.id)
    result = article_title(post, no_link: :true)
    assert_no_match /a href='#{url_for(post.url)}'>#{post.name}</, result
  end

  should "not create link on title if non-blog post" do
    article = fast_create(TextArticle, name: "art test", profile_id: profile.id)
    result = article_title(article)
    assert_no_match /a href='#{url_for(article.url)}'>#{article.name}</, result
  end

  should "not create link to comments if called with no_comments" do
    blog = fast_create(Blog, name: "Blog test", profile_id: profile.id)
    article = fast_create(TextArticle, name: "art test", profile_id: profile.id, parent_id: blog.id)
    result = article_title(article, no_comments: true)
    assert_no_match(/a href='.*comments_list.*>No comments yet</, result)
  end

  should "not create link to comments if the article doesn't allow comments" do
    blog = fast_create(Blog, name: "Blog test", profile_id: profile.id)
    article = fast_create(TextArticle, name: "art test", profile_id: profile.id, parent_id: blog.id, accept_comments: false)
    result = article_title(article)
    assert_no_match(/a href='.*comments_list.*>No comments yet</, result)
  end

  should "count total of comments from post" do
    article = fast_create(TextArticle, profile_id: profile.id)
    create(Comment, article: article, author: profile, title: "test", body: "test")
    article.reload
    result = link_to_comments(article)
    assert_match /One comment/, result
  end

  should "not display total of comments if the article doesn't allow comments" do
    article = build(TextArticle, name: "first post for test", body: "first post for test", profile: profile, accept_comments: false)
    article.stubs(:url).returns({})
    article.stubs(:comments).returns([build(Comment, author: profile, title: "test", body: "test")])
    result = link_to_comments(article)
    assert_equal "", result
  end

  should "not crash if spam_comments_count is nil" do
    article = TextArticle.new(name: "post for test", body: "post for test", profile: profile)
    article.stubs(:comments_count).returns(10)
    article.stubs(:spam_comments_count).returns(nil)
    result = number_of_comments(article)
    assert_match /10 comments/, result
  end

  should "not list feed article" do
    profile.articles << build(Blog, name: "Blog test", profile: profile)
    assert_includes profile.blog.children.map { |i| i.class }, RssFeed
    result = list_posts(profile.blog.posts)
    assert_no_match /feed/, result
  end

  should "theme provides addthis custom icon" do
    stubs(:session).returns(user_theme: "base")
    File.expects(:exists?).with(anything).returns(true)
    Environment.any_instance.stubs(:default_hostname).returns("noosfero.org")
    assert_match "addthis.gif", addthis_image_tag
  end

  should "use default addthis icon if theme has no addthis.gif image" do
    stubs(:session).returns(user_theme: "base")
    File.expects(:exists?).with(anything).returns(false)
    Environment.any_instance.stubs(:default_hostname).returns("noosfero.org")
    assert_match "bt-bookmark.gif", addthis_image_tag
  end

  should "show date with mm/dd/yyyy" do
    Environment.any_instance.stubs(:date_format).returns("numbers_with_year")
    article = TextArticle.new(name: "post for test", body: "post for test", profile: profile)
    article.published_at = Time.zone.local(2007, 2, 1, 15, 30, 45)
    article.save!
    result = show_with_right_format_date article
    assert_match /2\/1\/2007/, result
  end

  should "show date with mm/dd" do
    Environment.any_instance.stubs(:date_format).returns("numbers")
    article = TextArticle.new(name: "post for test", body: "post for test", profile: profile)
    article.published_at = Time.zone.local(2007, 2, 1, 15, 30, 45)
    article.save!
    result = show_with_right_format_date article
    assert_match /2\/1/, result
  end

  should "show date with month name" do
    Environment.any_instance.stubs(:date_format).returns("month_name")
    article = TextArticle.new(name: "post for test", body: "post for test", profile: profile)
    article.published_at = Time.zone.local(2007, 2, 1, 15, 30, 45)
    article.save!
    result = show_with_right_format_date article
    assert_match /February 1/, result
  end

  should "show date with month name and year" do
    Environment.any_instance.stubs(:date_format).returns("month_name_with_year")
    article = TextArticle.new(name: "post for test", body: "post for test", profile: profile)
    article.published_at = Time.zone.local(2007, 2, 1, 15, 30, 45)
    article.save!
    result = show_with_right_format_date article
    assert_match /February 1, 2007/, result
  end
end
