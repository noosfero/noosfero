require_relative "../test_helper"

class ArticleBlockTest < ActiveSupport::TestCase
  include ApplicationHelper

  should 'describe itself' do
    assert_not_equal Block.description, ArticleBlock.description
  end

  should 'refer to an article' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test article')
    article.save!

    block = ArticleBlock.new
    block.article = article

    block.save!

    assert_equal article, Block.find(block.id).article

  end

  should 'not crash when referenced article is removed' do
    person = create_user('testuser').person
    a = person.articles.create!(:name => 'test')
    block = ArticleBlock.create.tap do |b|
      b.article = a
    end
    person.boxes.first.blocks << block
    block.save!

    a.destroy
    block.reload
    assert_nil block.article
  end

  should 'nullify reference to unexisting article' do
    Article.delete_all

    block = ArticleBlock.new
    block.article_id = 999

    block.article
    assert_nil block.article_id
  end

  should "take available articles with a person as the box owner" do
    person = create_user('testuser').person
    person.articles.delete_all
    assert_equal [], person.articles
    a = person.articles.create!(:name => 'test')
    block = ArticleBlock.create.tap do |b|
      b.article = a
    end
    person.boxes.first.blocks << block
    block.save!

    block.reload
    assert_equal [a],block.available_articles
  end

  should "take available articles with an environment as the box owner" do
    env = Environment.create!(:name => 'test env')
    env.profiles.each { |profile| profile.articles.destroy_all }
    assert_equal [], env.articles
    community = fast_create(Community)
    a = fast_create(TextArticle, :profile_id => community.id, :name => 'test')
    env.portal_community=community
    env.save
    block = create(ArticleBlock, :article => a)
    env.boxes.first.blocks << block
    block.save!

    block.reload
    assert_equal [a],block.available_articles
  end

  protected
    include NoosferoTestHelper

end

require 'boxes_helper'
require 'block_helper'

class ArticleBlockViewTest < ActionView::TestCase
  include BoxesHelper

  ActionView::Base.send :include, ArticleHelper
  ActionView::Base.send :include, ButtonsHelper
  ActionView::Base.send :include, BlockHelper

  should "take article's content" do
    block = ArticleBlock.new
    article = mock
    article.expects(:to_html).returns("Article content")
    block.stubs(:article).returns(article)
    ActionView::Base.any_instance.stubs(:block_title).returns("")

    assert_match(/Article content/, render_block_content(block))
  end

  should "display empty title if title is blank" do
    block = ArticleBlock.new
    article = mock
    article.expects(:to_html).returns("Article content")
    block.expects(:title).returns('')
    block.stubs(:article).returns(article)

    assert_tag_in_string render_block_content(block),
         :tag => 'h3', :attributes => {:class => 'block-title empty'},
         :descendant => { :tag => 'span' }
  end

  should "display title if defined" do
    block = ArticleBlock.new
    article = mock
    article.expects(:to_html).returns("Article content")
    block.expects(:title).returns('Article title')
    block.stubs(:article).returns(article)

    assert_tag_in_string render_block_content(block),
          :tag => 'h3', :attributes => {:class => 'block-title'},
          :descendant => { :tag => 'span', :content => 'Article title' }
  end

  should 'display image if article is an image' do
    profile = create_user('testuser').person
    block = ArticleBlock.new
    image = create(UploadedFile, :profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    block.article = image
    block.save!

    assert_tag_in_string render_block_content(block),
        :tag => 'img',
        :attributes => {
            :src => image.public_filename(:display),
            :class => /file-image/
        }
  end

  should 'not display gallery pages navigation in content' do
    profile = create_user('testuser').person
    block = ArticleBlock.new
    gallery = fast_create(Gallery, :profile_id => profile.id)
    image = create(UploadedFile, :profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :parent => gallery)
    block.article = image
    block.save!

    assert_no_match(/Previous/, render_block_content(block))
  end

  should 'display link to archive if article is an archive' do
    profile = create_user('testuser').person
    block = ArticleBlock.new
    file = create(UploadedFile, :profile => profile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))

    block.article = file
    block.save!

    UploadedFile.any_instance.stubs(:url).returns('myhost.mydomain/path/to/file')
    assert_tag_in_string render_block_content(block), :tag => 'a', :content => _('Download')
  end
end
