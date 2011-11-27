require File.dirname(__FILE__) + '/../test_helper'

class ContentViewerHelperTest < ActiveSupport::TestCase

  include ActionView::Helpers::TagHelper
  include ContentViewerHelper
  include DatesHelper
  include ApplicationHelper

  def setup
    @profile = create_user('blog_helper_test').person
  end
  attr :profile

  should 'display published-at for blog posts' do
    blog = fast_create(Blog, :name => 'Blog test', :profile_id => profile.id)
    post = TextileArticle.create!(:name => 'post test', :profile => profile, :parent => blog)
    result = article_title(post)
    assert_match /<span class="date">#{show_date(post.published_at)}<\/span><span class="author">, by .*#{profile.identifier}/, result
  end

  should 'not display published-at for non-blog posts' do
    article = TextileArticle.create!(:name => 'article for test', :profile => profile)
    result = article_title(article)
    assert_no_match /<span class="date">#{show_date(article.published_at)}<\/span><span class="author">, by .*#{profile.identifier}/, result
  end

  should 'create link on title of blog posts' do
    blog = fast_create(Blog, :name => 'Blog test', :profile_id => profile.id)
    post = fast_create(TextileArticle, :name => 'post test', :profile_id => profile.id, :parent_id => blog.id)
    assert post.belongs_to_blog?
    result = article_title(post)
    assert_tag_in_string result, :tag => 'h1', :child => {:tag => 'a', :content => 'post test', :attributes => { :href => /my-article-\d+/ }}
  end

  should 'not create link on title if pass no_link option' do
    blog = fast_create(Blog, :name => 'Blog test', :profile_id => profile.id)
    post = fast_create(TextileArticle, :name => 'post test', :profile_id => profile.id, :parent_id => blog.id)
    result = article_title(post, :no_link => :true)
    assert_no_match /a href='#{post.url}'>#{post.name}</, result
  end

  should 'not create link on title if non-blog post' do
    article = fast_create(TextileArticle, :name => 'art test', :profile_id => profile.id)
    result = article_title(article)
    assert_no_match /a href='#{article.url}'>#{article.name}</, result
  end

  should 'not create link to comments if called with no_comments' do
    blog = fast_create(Blog, :name => 'Blog test', :profile_id => profile.id)
    article = fast_create(TextileArticle, :name => 'art test', :profile_id => profile.id, :parent_id => blog.id)
    result = article_title(article, :no_comments => true)
    assert_no_match(/a href='.*comments_list.*>No comments yet</, result)
  end

  should 'not create link to comments if the article doesn\'t allow comments' do
    blog = fast_create(Blog, :name => 'Blog test', :profile_id => profile.id)
    article = fast_create(TextileArticle, :name => 'art test', :profile_id => profile.id, :parent_id => blog.id, :accept_comments => false)
    result = article_title(article)
    assert_no_match(/a href='.*comments_list.*>No comments yet</, result)
  end

  should 'count total of comments from post' do
    article = TextileArticle.new(:name => 'first post for test', :body => 'first post for test', :profile => profile)
    article.stubs(:url).returns({})
    article.stubs(:comments).returns([Comment.new(:author => profile, :title => 'test', :body => 'test')])
    result = link_to_comments(article)
    assert_match /One comment/, result
  end

  should 'not display total of comments if the article doesn\'t allow comments' do
    article = TextileArticle.new(:name => 'first post for test', :body => 'first post for test', :profile => profile, :accept_comments => false)
    article.stubs(:url).returns({})
    article.stubs(:comments).returns([Comment.new(:author => profile, :title => 'test', :body => 'test')])
    result = link_to_comments(article)
    assert_equal '', result
  end

  should 'not list feed article' do
    profile.articles << Blog.new(:name => 'Blog test', :profile => profile)
    assert_includes profile.blog.children.map{|i| i.class}, RssFeed
    result = list_posts(profile.blog.posts)
    assert_no_match /feed/, result
  end

  should 'generate facebook addthis url for article' do
    Environment.any_instance.stubs(:default_hostname).returns('noosfero.org')
    [TextileArticle, Blog, Folder, Gallery, UploadedFile, Forum, Event, TextArticle, TinyMceArticle].each do |model|
      a = model.new(:name => 'Some title', :body => 'Some text here.', :profile => profile)
      assert_equal "http://www.facebook.com/sharer.php?s=100&p[title]=Some+title&p[summary]=Some+text+here.&p[url]=http%3A%2F%2Fnoosfero.org%2Fblog_helper_test%2Fsome-title&p[images][0]=", addthis_facebook_url(a)
    end
  end

  should 'generate facebook addthis url without body' do
    Environment.any_instance.stubs(:default_hostname).returns('noosfero.org')
    a = TinyMceArticle.new(:name => 'Test', :body => nil, :profile => profile)
    assert_equal "http://www.facebook.com/sharer.php?s=100&p[title]=Test&p[summary]=&p[url]=http%3A%2F%2Fnoosfero.org%2Fblog_helper_test%2Ftest&p[images][0]=", addthis_facebook_url(a)
  end

  should 'generate facebook addthis url without tags in body' do
    Environment.any_instance.stubs(:default_hostname).returns('noosfero.org')
    a = TinyMceArticle.new(:name => 'Some title', :body => '<p>This <b class="bold">is</b> a test</p>', :profile => profile)
    assert_equal "http://www.facebook.com/sharer.php?s=100&p[title]=Some+title&p[summary]=This+is+a+test&p[url]=http%3A%2F%2Fnoosfero.org%2Fblog_helper_test%2Fsome-title&p[images][0]=", addthis_facebook_url(a)
  end

  should 'generate facebook addthis url with truncated body' do
    Environment.any_instance.stubs(:default_hostname).returns('noosfero.org')
    a = TinyMceArticle.new(:name => 'Some title', :body => 'test' * 76, :profile => profile)
    assert_equal "http://www.facebook.com/sharer.php?s=100&p[title]=Some+title&p[summary]=#{'test' * 74}t...&p[url]=http%3A%2F%2Fnoosfero.org%2Fblog_helper_test%2Fsome-title&p[images][0]=", addthis_facebook_url(a)
  end

  should 'generate facebook addthis url for tinymce article with images' do
    Environment.any_instance.stubs(:default_hostname).returns('noosfero.org')
    a = TinyMceArticle.new(:name => 'Some title', :body => '<p>This <b class="bold">is</b> a <img src="/images/x.png" />test</p>', :profile => profile)
    assert_equal "http://www.facebook.com/sharer.php?s=100&p[title]=Some+title&p[summary]=This+is+a+test&p[url]=http%3A%2F%2Fnoosfero.org%2Fblog_helper_test%2Fsome-title&p[images][0]=http%3A%2F%2Fnoosfero.org%2Fimages%2Fx.png", addthis_facebook_url(a)
  end

  should 'theme provides addthis custom icon' do
    stubs(:session).returns({:theme => 'base'})
    File.expects(:exists?).with(anything).returns(true)
    Environment.any_instance.stubs(:default_hostname).returns('noosfero.org')
    assert_match 'addthis.gif', addthis_image_tag
  end

  should 'use default addthis icon if theme has no addthis.gif image' do
    stubs(:session).returns({:theme => 'base'})
    File.expects(:exists?).with(anything).returns(false)
    Environment.any_instance.stubs(:default_hostname).returns('noosfero.org')
    assert_match 'bt-bookmark.gif', addthis_image_tag
  end

  protected
  include NoosferoTestHelper
  include ActionView::Helpers::TextHelper
  def url_for(args = {})
    ['http:/', args[:host], args[:profile], args[:page]].join('/')
  end

end
