require File.dirname(__FILE__) + '/../test_helper'

class ArticleBlockTest < Test::Unit::TestCase

  should 'describe itself' do
    assert_not_equal Block.description, ArticleBlock.description
  end

  should "take article's content" do
    block = ArticleBlock.new
    article = mock
    article.expects(:to_html).returns("Article content")
    block.stubs(:article).returns(article)

    assert_match(/Article content/, block.content)
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

  should "take available articles with a person as the box owner" do
    person = create_user('testuser').person
    person.articles.delete_all
    assert_equal [], person.articles
    a = person.articles.create!(:name => 'test')
    block = ArticleBlock.create(:article => a)
    person.boxes.first.blocks << block
    block.save!
    
    block.reload
    assert_equal [a],block.available_articles
  end

  should "take available articles with an environment as the box owner" do
    env = Environment.create!(:name => 'test env')
    env.articles.destroy_all
    assert_equal [], env.articles
    community = fast_create(Community)
    a = community.articles.create!(:name => 'test')
    env.portal_community=community
    env.save
    block = ArticleBlock.create(:article => a)
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

    assert_equal "<h3 class=\"block-title empty\"></h3>Article content", block.content
  end

  should "display title if defined" do
    block = ArticleBlock.new
    article = mock
    article.expects(:to_html).returns("Article content")
    block.expects(:title).returns('Article title')
    block.stubs(:article).returns(article)

    assert_equal "<h3 class=\"block-title\">Article title</h3>Article content", block.content
  end

end
