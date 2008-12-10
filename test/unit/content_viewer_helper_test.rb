require File.dirname(__FILE__) + '/../test_helper'

class ContentViewerHelperTest < Test::Unit::TestCase

  include ActionView::Helpers::TagHelper
  include ContentViewerHelper

  def setup
    @profile = create_user('blog_helper_test').person
  end
  attr :profile

  should 'display created-at for blog posts' do
    blog = Blog.create!(:name => 'Blog test', :profile => profile)
    post = TextileArticle.create!(:name => 'post test', :profile => profile, :parent => blog)
    result = article_title(post)
    assert_match /#{post.created_at}, by #{profile.identifier}/, result
  end

  should 'not display created-at for non-blog posts' do
    article = TextileArticle.create!(:name => 'article for test', :profile => profile)
    result = article_title(article)
    assert_no_match /#{article.created_at}, by #{profile.identifier}/, result
  end

  should 'create link on title of blog posts' do
    blog = Blog.create!(:name => 'Blog test', :profile => profile)
    post = TextileArticle.create!(:name => 'post test', :profile => profile, :parent => blog)
    assert post.belongs_to_blog?
    result = article_title(post)
    assert_match /a href='#{post.url}'>#{post.name}</, result
  end

  should 'not create link on title if pass no_link option' do
    blog = Blog.create!(:name => 'Blog test', :profile => profile)
    post = TextileArticle.create!(:name => 'post test', :profile => profile, :parent => blog)
    result = article_title(post, :no_link => :true)
    assert_no_match /a href='#{post.url}'>#{post.name}</, result
  end

  should 'not create link on title if non-blog post' do
    article = TextileArticle.create!(:name => 'art test', :profile => profile)
    result = article_title(article)
    assert_no_match /a href='#{article.url}'>#{article.name}</, result
  end

  should 'count total of comments from post' do
    article = TextileArticle.new(:name => 'first post for test', :body => 'first post for test', :profile => profile)
    article.stubs(:url).returns({})
    article.stubs(:comments).returns([Comment.new(:author => profile, :title => 'test', :body => 'test')])
    result = display_post(article)
    assert_match /One comment/, result
  end

  should 'not list feed article' do
    profile.articles << Blog.new(:name => 'Blog test')
    assert_includes profile.blog.children.map{|i| i.class}, RssFeed
    result = list_posts(profile.blog.posts)
    assert_no_match /feed/, result
  end

  should 'filter blog posts by date' do
    blog = Blog.create!(:name => 'Blog test', :profile => profile)

    nov = TextileArticle.create!(:name => 'November post', :parent => blog, :profile => profile)
    nov.update_attributes!(:created_at => DateTime.parse('2008-11-15'))

    sep = TextileArticle.create!(:name => 'September post', :parent => blog, :profile => profile)
    sep.update_attribute(:created_at, DateTime.parse('2008-09-10'))

    blog.reload
    blog.filter = {:year => 2008, :month => 11}
    assert blog.save!

    self.stubs(:params).returns({:npage => nil})

    result = article_to_html(blog)

    assert_match /November post/, result
    assert_no_match /September post/, result
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
