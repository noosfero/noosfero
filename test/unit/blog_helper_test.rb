require_relative "../test_helper"

class BlogHelperTest < ActionView::TestCase

  include BlogHelper
  include ContentViewerHelper
  include ActionView::Helpers::AssetTagHelper
  include ApplicationHelper

  helper ApplicationHelper

  def setup
    stubs(:show_date).returns('')
    @environment = Environment.default
    @profile = create_user('blog_helper_test').person
    @blog = fast_create(Blog, :profile_id => profile.id, :name => 'Blog test')
  end

  attr :profile
  attr :blog

  def _(s); s; end
  def h(s); s; end

  should 'list blog posts with identifiers and classes' do
    blog.children << older_post = create(TextileArticle, :name => 'First post',
                     :profile => profile, :parent => blog, :published => true)
    blog.children << some_post = create(TextileArticle, :name => 'Some post',
                     :profile => profile, :parent => blog, :published => true)
    blog.children << hidden_post = create(TextileArticle, :name => 'Hidden post',
                     :profile => profile, :parent => blog, :published => false)
    blog.children << newer_post = create(TextileArticle, :name => 'Last post',
                     :profile => profile, :parent => blog, :published => true)

    def content_tag(tag, content_or_options_with_block = nil, options = nil, &block)
      if block_given?
        options = content_or_options_with_block
        content = block.call
      else
        content = content_or_options_with_block
      end
      options ||= {}
      "<#{tag}#{options.map{|k,v| " #{k}=\"#{[v].flatten.join(' ')}\""}.join}>#{content}</#{tag}>"
    end

    html = Nokogiri::HTML list_posts(blog.posts)
    assert_select html, "div#post-#{newer_post.id}.blog-post.position-1.first.odd-post" +
                        " > div.odd-post-inner.blog-post-inner > .title", 'Last post'
    assert_select html, "div#post-#{hidden_post.id}.blog-post.position-2.not-published.even-post" +
                        " > div.even-post-inner.blog-post-inner > .title", 'Hidden post'
    assert_select html, "div#post-#{some_post.id}.blog-post.position-3.odd-post" +
                        " > div.odd-post-inner.blog-post-inner > .title", 'Some post'
    assert_select html, "div#post-#{older_post.id}.blog-post.position-4.last.even-post" +
                        " > div.even-post-inner.blog-post-inner > .title", 'First post'
  end


  should 'display post' do
    blog.children << article = create(TextileArticle, :name => 'Second post', :profile => profile, :parent => blog, :published => true)
    expects(:article_title).with(article, anything).returns('TITLE')
    expects(:content_tag).with('p', article.to_html).returns(' TO_HTML')
    self.stubs(:params).returns({:npage => nil})

    assert_equal 'TITLE TO_HTML', display_post(article)
  end

  should 'display empty post if body is nil' do
    blog.children << article = fast_create(Article, :profile_id => profile.id, :parent_id => blog.id, :body => nil)
    expects(:article_title).with(article, anything).returns('TITLE')
    expects(:content_tag).with('p', '').returns('')
    self.stubs(:params).returns({:npage => nil})

    assert_equal 'TITLE', display_post(article)
  end

  should 'display full post by default' do
    blog.children << article = fast_create(Article, :profile_id => profile.id, :parent_id => blog.id, :body => nil)
    expects(:article_title).with(article, anything).returns('')
    expects(:display_full_format).with(article).returns('FULL POST')

    assert_equal 'FULL POST', display_post(article)
  end

  should 'no_comments is false if blog displays full post' do
    blog.children << article = fast_create(Article, :profile_id => profile.id, :parent_id => blog.id, :body => nil)
    expects(:article_title).with(article, :no_comments => false).returns('')
    expects(:display_full_format).with(article).returns('FULL POST')

    assert_equal 'FULL POST', display_post(article, 'full')
  end

  should 'no_comments is true if blog displays short post' do
    blog.update_attribute(:visualization_format, 'short')
    blog.children << article = fast_create(Article, :profile_id => profile.id, :parent_id => blog.id, :body => nil)
    expects(:article_title).with(article, :no_comments => true).returns('')
    expects(:display_short_format).with(article).returns('SHORT POST')

    assert_equal 'SHORT POST', display_post(article, 'short')
  end


  should 'display link to file if post is an uploaded_file' do
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'), :profile => profile, :published => true, :parent => blog)
    result = display_post(file)

    assert_tag_in_string result, :tag => 'a', :content => _('Download')
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
  include NoosferoTestHelper

end
