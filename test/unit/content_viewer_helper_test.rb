require File.dirname(__FILE__) + '/../test_helper'

class ContentViewerHelperTest < Test::Unit::TestCase

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
    assert_match /#{show_date(post.published_at)}, by .*#{profile.identifier}/, result
  end

  should 'not display published-at for non-blog posts' do
    article = TextileArticle.create!(:name => 'article for test', :profile => profile)
    result = article_title(article)
    assert_no_match /#{show_date(article.published_at)}, by .*#{profile.identifier}/, result
  end

  should 'create link on title of blog posts' do
    blog = fast_create(Blog, :name => 'Blog test', :profile_id => profile.id)
    post = fast_create(TextileArticle, :name => 'post test', :profile_id => profile.id, :parent_id => blog.id)
    assert post.belongs_to_blog?
    result = article_title(post)
    assert_match /a href='#{post.url}'>#{post.name}</, result
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

end

def show_date(date)
  date.to_s
end
def link_to(content, url)
  "<a href='#{url}'>#{content}</a>"
end
def _(text)
  text
end
def will_paginate(arg1, arg2)
end
