require File.dirname(__FILE__) + '/../test_helper'

class BlogHelperTest < Test::Unit::TestCase

  include BlogHelper
  include ContentViewerHelper

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
    expects(:content_tag).with('div', "POST<br style=\"clear:both\"/>", :class => 'blog-post position-1 first last', :id => "post-#{published_post.id}").returns('RESULT')

    assert_equal 'RESULT', list_posts(profile, blog.posts)
  end

  should 'list unpublished posts to owner with a different class' do
    blog.children << unpublished_post = TextileArticle.create!(:name => 'Post', :profile => profile, :parent => blog, :published => false)

    expects(:display_post).with(anything).returns('POST')
    expects(:content_tag).with('div', "POST<br style=\"clear:both\"/>", :class => 'blog-post position-1 first last not-published', :id => "post-#{unpublished_post.id}").returns('RESULT')

    assert_equal 'RESULT', list_posts(profile, blog.posts)
  end

  should 'not list unpublished posts to not owner' do
    blog.children << unpublished_post = TextileArticle.create!(:name => 'First post', :profile => profile, :parent => blog, :published => false)

    blog.children << published_post = TextileArticle.create!(:name => 'Second post', :profile => profile, :parent => blog, :published => true)

    expects(:display_post).with(anything).returns('POST')
    expects(:content_tag).with('div', "POST<br style=\"clear:both\"/>", has_entries(:id => "post-#{published_post.id}")).returns('RESULT')
    expects(:content_tag).with('div', "POST<br style=\"clear:both\"/>", has_entries(:id => "post-#{unpublished_post.id}")).never

    assert_equal 'RESULT', list_posts(nil, blog.posts)
  end

  should 'display post' do
    blog.children << article = TextileArticle.create!(:name => 'Second post', :profile => profile, :parent => blog, :published => true)
    expects(:article_title).with(article).returns('TITLE')
    expects(:content_tag).with('p', article.to_html).returns(' TO_HTML')
    self.stubs(:params).returns({:npage => nil})

    assert_equal 'TITLE TO_HTML', display_post(article)
  end

  should 'display link to file if post is an uploaded_file' do
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'), :profile => profile, :published => true, :parent => blog)

    expects(:article_to_html).with(file).returns('TO HTML')

    result = display_post(file)
    assert_tag_in_string result, :content => /TO HTML/
  end

  should 'display image if post is an image' do
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => profile, :published => true, :parent => blog)

    self.stubs(:params).returns({:npage => nil})

    display_filename = file.public_filename(:display)

    result = display_post(file)
    assert_match /rails.png/, result
    assert_tag_in_string result, :tag => 'img', :attributes => { :src => /#{display_filename}/ }
  end

  protected

  def will_paginate(arg1, arg2)
  end

  def link_to(content, url)
    content
  end

  def tag(tag, args = {})
    attrs = args.map{|k,v| "#{k}='#{v}'"}.join(' ')
    "<#{tag} #{attrs} />"
  end

  def content_tag(tag, content, options = {})
    "<#{tag}>#{content}</#{tag}>"
  end
end
