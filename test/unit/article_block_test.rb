require File.dirname(__FILE__) + '/../test_helper'

class ArticleBlockTest < Test::Unit::TestCase

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
    block = ArticleBlock.create(:article => a)
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

  should "display empty title if title is blank" do
    block = ArticleBlock.new
    article = mock
    article.expects(:to_html).returns("Article content")
    block.expects(:title).returns('')
    block.stubs(:article).returns(article)

    assert_equal "<h3></h3>Article content", instance_eval(&block.content)
  end

  should "display title if defined" do
    block = ArticleBlock.new
    article = mock
    article.expects(:to_html).returns("Article content")
    block.expects(:title).returns('Article title')
    block.stubs(:article).returns(article)

    assert_equal "<h3>Article title</h3>Article content", instance_eval(&block.content)
  end

  should 'display image if article is an image' do
    profile = create_user('testuser').person
    block = ArticleBlock.new
    image = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    block.article = image
    block.save!

    expects(:image_tag).with(image.public_filename(:display), :class => image.css_class_name, :style => 'max-width: 100%').returns('image')

    assert_match(/image/, instance_eval(&block.content))
  end

  should 'display link to archive if article is an archive' do
    profile = create_user('testuser').person
    block = ArticleBlock.new
    file = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))

    block.article = file
    block.save!

    assert_tag_in_string instance_eval(&block.content), :tag => 'a', :content => 'test.txt'
  end

  protected

    def content_tag(tag, text, options = {})
      "<#{tag}>#{text}</#{tag}>"
    end
    def image_tag(arg)
      arg
    end
    def link_to(text, url, options = {})
      "<a href='#{url.to_s}'>#{text}</a>"
    end
    def params
      {}
    end
end
