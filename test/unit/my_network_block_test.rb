require File.dirname(__FILE__) + '/../test_helper'

class MyNetworkBlockTest < ActiveSupport::TestCase

  def setup
    @block = MyNetworkBlock.new
    @owner = Person.new(:identifier => 'testuser')
    @block.stubs(:owner).returns(@owner)

    owner.stubs(:environment).returns(Environment.default)
  end
  attr_reader :owner, :block

  should 'provide description' do
    assert_not_equal Block.description, MyNetworkBlock.description
  end

  should 'provide default title' do
    assert_not_equal Block.new.default_title, MyNetworkBlock.new.default_title
  end

  should 'count articles' do
    mock_articles = mock
    owner.stubs(:articles).returns(mock_articles)
    owner.stubs(:tags).returns({}) # don't let tags call articles
    mock_articles.stubs(:count).returns(5)

    assert_tag_in_string block.content, :tag => 'li', :descendant => { :tag => 'a', :content => '5 articles published', :attributes => { :href => /\/profile\/testuser\/sitemap$/ } }
  end

  should 'count friends' do
    mock_friends = mock
    owner.stubs(:friends).returns(mock_friends)
    mock_friends.stubs(:count).returns(8)

    assert_tag_in_string block.content, :tag => 'li', :descendant => { :tag => 'a', :content => '8 friends', :attributes => { :href => /\profile\/testuser\/friends/ }}
  end

  should 'count communities' do
    mock_communities = mock
    owner.stubs(:communities).returns(mock_communities)
    mock_communities.stubs(:count).returns(23)

    assert_tag_in_string block.content, :tag => 'li', :descendant => { :tag => 'a', :content => '23 communities', :attributes => { :href => /\profile\/testuser\/communities/ }}
  end

  should 'count tags' do
    mock_tags = mock
    owner.stubs(:tags).returns(mock_tags)
    mock_tags.stubs(:count).returns(436)

    assert_tag_in_string block.content, :tag => 'li', :descendant => { :tag => 'a', :content => '436 tags', :attributes => { :href => /\profile\/testuser\/tags/ }}
  end

  should 'display its title' do
    block.stubs(:title).returns('My Network')
    assert_tag_in_string block.content, :content => 'My Network'
  end

end
