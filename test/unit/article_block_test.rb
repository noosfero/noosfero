require File.dirname(__FILE__) + '/../test_helper'

class ArticleBlockTest < Test::Unit::TestCase

  should 'describe itself' do
    assert_not_equal Block.description, ArticleBlock.description
  end

  should "take article's content" do
    block = ArticleBlock.new
    html = mock
    article = mock
    article.expects(:to_html).returns(html)
    block.stubs(:article).returns(article)

    assert_same html, block.content
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

end
