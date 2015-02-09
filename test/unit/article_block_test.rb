require_relative "../test_helper"

class ArticleBlockTest < ActiveSupport::TestCase
  include ApplicationHelper

  should 'describe itself' do
    assert_not_equal Block.description, ArticleBlock.description
  end

  should "take article's content" do
    block = ArticleBlock.new
    article = mock
    article.expects(:to_html).returns("Article content")
    block.stubs(:article).returns(article)

    assert_match(/Article content/, instance_eval(&block.content))
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

  should "display empty title if title is blank" do
    block = ArticleBlock.new
    article = mock
    article.expects(:to_html).returns("Article content")
    block.expects(:title).returns('')
    block.stubs(:article).returns(article)

    assert_equal "<h3 class=\"block-title empty\"><span></span></h3>Article content", instance_eval(&block.content)
  end

  should "display title if defined" do
    block = ArticleBlock.new
    article = mock
    article.expects(:to_html).returns("Article content")
    block.expects(:title).returns('Article title')
    block.stubs(:article).returns(article)

    assert_equal "<h3 class=\"block-title\"><span>Article title</span></h3>Article content", instance_eval(&block.content)
  end

  should 'display image if article is an image' do
    profile = create_user('testuser').person
    block = ArticleBlock.new
    image = create(UploadedFile, :profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    block.article = image
    block.save!

    assert_tag_in_string instance_eval(&block.content),
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

    assert_no_match(/Previous/, instance_eval(&block.content))
  end

  should 'display link to archive if article is an archive' do
    profile = create_user('testuser').person
    block = ArticleBlock.new
    file = create(UploadedFile, :profile => profile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))

    block.article = file
    block.save!

    assert_tag_in_string instance_eval(&block.content), :tag => 'a', :content => 'test.txt'
  end

  protected
    include NoosferoTestHelper

end
