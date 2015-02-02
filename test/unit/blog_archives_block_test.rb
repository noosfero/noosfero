require_relative "../test_helper"

class BlogArchivesBlockTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('flatline').person
    @profile.articles << Blog.new(:name => 'Blog One', :profile => @profile)
  end
  attr_reader :profile

  should 'default describe' do
    assert_not_equal Block.description, BlogArchivesBlock.description
  end

  should 'is editable' do
    l = BlogArchivesBlock.new
    assert l.editable?
  end

  should 'list amount posts by year' do
    date = DateTime.parse('2008-01-10')
    blog = profile.blog
    for i in 1..10 do
      post = fast_create(TextileArticle, :name => "post #{i} test", :profile_id => profile.id, :parent_id => blog.id)
      post.update_attribute(:published_at, date)
    end
    block = BlogArchivesBlock.new
    block.stubs(:owner).returns(profile)
    assert_tag_in_string block.content, :tag => 'li', :content => '2008 (10)'
  end

  should 'list amount posts by month' do
    date = DateTime.parse('2008-01-10')
    blog = profile.blog
    for i in 1..10 do
      post = fast_create(TextileArticle, :name => "post #{i} test", :profile_id => profile.id, :parent_id => blog.id)
      assert post.update_attribute(:published_at, date)
    end
    block = BlogArchivesBlock.new
    block.stubs(:owner).returns(profile)
    assert_tag_in_string block.content, :tag => 'a', :content => 'January (10)', :attributes => {:href => /^http:\/\/.*\/flatline\/blog-one\?month=1&year=2008$/ }
  end

  should 'order list of amount posts' do
    blog = profile.blog
    for i in 1..10 do
      post = fast_create(TextileArticle, :name => "post #{i} test", :profile_id => profile.id, :parent_id => blog.id)
      post.update_attribute(:published_at, DateTime.parse("2008-#{i}-01"))
    end
    block = BlogArchivesBlock.new
    block.stubs(:owner).returns(profile)
    assert_tag_in_string block.content, :tag => 'li', :content => 'January (1)',
      :sibling => {:tag => 'li', :content => 'February (1)',
        :sibling => {:tag => 'li', :content => 'March (1)',
          :sibling => {:tag => 'li', :content => 'April (1)',
            :sibling => {:tag => 'li', :content => 'May (1)'}}}}
  end

  should 'order years' do
    blog = profile.blog
    for year in 2005..2009
      post = create(TextileArticle, :name => "post #{year}", :profile => profile, :parent => blog, :published_at => Date.new(year, 1, 1))
    end
    block = BlogArchivesBlock.new
    block.stubs(:owner).returns(profile)
    assert_match(/2009.*2008.*2007.*2006.*2005/m, block.content)
  end

  should 'order months from later to former' do
    blog = profile.blog
    for month in 1..3
      post = create(TextileArticle, :name => "post #{month}", :profile => profile, :parent => blog, :published_at => Date.new(2009, month, 1))
    end
    block = BlogArchivesBlock.new
    block.stubs(:owner).returns(profile)
    assert_match(/.*March.*February.*January.*/m, block.content)
  end

  should 'not display any content if has no blog' do
    profile.blogs.destroy_all
    block = BlogArchivesBlock.new
    block.stubs(:owner).returns(profile)
    assert_nil block.content
  end

  should 'has field to configure blog' do
    b = BlogArchivesBlock.new
    assert b.respond_to?(:blog_id)
    assert b.respond_to?(:blog_id=)
  end

  should 'show posts from first blog' do
    profile.articles << Blog.new(:name => 'Blog Two', :profile => profile)
    (blog_one, blog_two) = profile.blogs
    for month in 1..3
      create(TextileArticle, :name => "blog one - post #{month}", :profile_id => profile.id, :parent_id => blog_one.id)
      create(TextileArticle, :name => "blog two - post #{month}", :profile_id => profile.id, :parent_id => blog_two.id)
    end
    block = BlogArchivesBlock.new
    block.stubs(:owner).returns(profile)
    assert_match(/blog-one/m, block.content)
    assert_no_match(/blog-two/m, block.content)
  end

  should 'list amount native posts by year' do
    date = DateTime.parse('2008-01-10')
    blog = profile.blog
    2.times do |i|
      post = fast_create(TextileArticle, :name => "post #{i} test", :profile_id => profile.id,
                         :parent_id => blog.id, :language => 'en')
      post.update_attribute(:published_at, date)
      translation = fast_create(TextileArticle, :name => "post #{i} test", :profile_id => profile.id,
                  :parent_id => blog.id, :language => 'en', :translation_of_id => post.id)
      translation.update_attribute(:published_at, date)
    end
    block = BlogArchivesBlock.new
    block.stubs(:owner).returns(profile)
    assert_tag_in_string block.content, :tag => 'li', :content => '2008 (2)'
  end

  should 'list amount native posts by month' do
    date = DateTime.parse('2008-01-10')
    blog = profile.blog
    2.times do |i|
      post = fast_create(TextileArticle, :name => "post #{i} test", :profile_id => profile.id,
                         :parent_id => blog.id, :language => 'en')
      post.update_attribute(:published_at, date)
      translation = fast_create(TextileArticle, :name => "post #{i} test", :profile_id => profile.id,
                  :parent_id => blog.id, :language => 'en', :translation_of_id => post.id)
      translation.update_attribute(:published_at, date)
    end
    block = BlogArchivesBlock.new
    block.stubs(:owner).returns(profile)
    assert_tag_in_string block.content, :tag => 'a', :content => 'January (2)', :attributes => {:href => /^http:\/\/.*\/flatline\/blog-one\?month=1&year=2008$/ }
  end

  should 'not try to load a removed blog' do
    block = fast_create(BlogArchivesBlock)
    block.blog_id = profile.blog.id
    block.save!
    block.stubs(:owner).returns(profile)
    profile.blog.destroy
    assert_nothing_raised do
      assert_nil block.blog
    end
  end

  should 'load next blog if configured blog was removed' do
    other_blog = fast_create(Blog, :profile_id => profile.id)
    block = fast_create(BlogArchivesBlock)
    block.blog_id = profile.blog.id
    block.save!
    block.stubs(:owner).returns(profile)
    profile.blog.destroy
    assert_nothing_raised do
      assert_equal other_blog, block.blog
    end
  end

#FIXME Performance issues with display_to. Must convert it to a scope.
# Checkout this page for further information: http://noosfero.org/Development/ActionItem2705
#
#  should 'not count articles if the user can\'t see them' do
#    person = create_user('testuser').person
#    blog = fast_create(Blog, :profile_id => profile.id, :path => 'blog_path')
#    block = fast_create(BlogArchivesBlock)
#
#    feed = mock()
#    feed.stubs(:url).returns(blog.url)
#    blog.stubs(:feed).returns(feed)
#    block.stubs(:blog).returns(blog)
#    block.stubs(:owner).returns(profile)
#
#    public_post = fast_create(TextileArticle, :profile_id => profile.id, :parent_id => blog.id, :published => true, :published_at => Time.mktime(2012, 'jan'))
#    private_post = fast_create(TextileArticle, :profile_id => profile.id, :parent_id => blog.id, :published => false, :published_at => Time.mktime(2012, 'jan'))
#
#    assert_match /January \(1\)/, block.content({:person => person})
#    assert_match /January \(1\)/, block.content()
#    assert_match /January \(2\)/, block.content({:person => profile})
#  end
end
