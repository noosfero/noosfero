require File.dirname(__FILE__) + '/../test_helper'

class BlogHelperTest < Test::Unit::TestCase

  include BlogHelper

  def setup
    stubs(:show_date).returns('')
    @environment = Environment.default
    @profile = create_user('blog_helper_test').person
    @blog = Blog.create!(:profile => profile, :name => 'Blog test')
  end

  attr :profile
  attr :blog

  def _(s); s; end

  should 'list published posts with class blog-post' do
    blog.children << published_post = TextileArticle.create!(:name => 'Post', :profile => profile, :parent => blog, :published => true)

    expects(:display_post).with(anything).returns('POST')
    expects(:content_tag).with('div', 'POST', :class => 'blog-post', :id => "post-#{published_post.id}").returns('RESULT')

    assert_equal 'RESULT', list_posts(profile, blog.posts)
  end

  should 'list unpublished posts to owner with a different class' do
    blog.children << unpublished_post = TextileArticle.create!(:name => 'Post', :profile => profile, :parent => blog, :published => false)

    expects(:display_post).with(anything).returns('POST')
    expects(:content_tag).with('div', 'POST', :class => 'blog-post-not-published', :id => "post-#{unpublished_post.id}").returns('RESULT')

    assert_equal 'RESULT', list_posts(profile, blog.posts)
  end

  should 'not list unpublished posts to not owner' do
    blog.children << unpublished_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => blog, :published => false)

    blog.children << published_post = TextileArticle.create!(:name => 'Second post', :profile => profile, :parent => blog, :published => true)

    expects(:display_post).with(anything).returns('POST')
    expects(:content_tag).with('div', 'POST', :class => 'blog-post', :id => "post-#{published_post.id}").returns('RESULT')
    expects(:content_tag).with('div', 'POST', :class => 'blog-post-not-published', :id => "post-#{unpublished_post.id}").never

    assert_equal 'RESULT', list_posts(nil, blog.posts)
  end

  should 'display post' do
    blog.children << article = TextileArticle.create!(:name => 'Second post', :profile => profile, :parent => blog, :published => true)
    expects(:article_title).with(article).returns('TITLE')
    expects(:content_tag).with('p', article.to_html).returns(' TO_HTML')

    assert_equal 'TITLE TO_HTML', display_post(article)
  end

  def will_paginate(arg1, arg2)
  end

  def link_to(content, url)
    content
  end

  def content_tag(tag, content, options = {})
    "<#{tag}>#{content}</#{tag}>"
  end
end
