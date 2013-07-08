require File.dirname(__FILE__) + '/../test_helper'

class TagsBlockTest < ActiveSupport::TestCase

  def setup
    @user = create_user('testinguser').person
    @user.articles.build(:name => 'article 1', :tag_list => 'first-tag').save!
    @user.articles.build(:name => 'article 2', :tag_list => 'first-tag, second-tag').save!
    @user.articles.build(:name => 'article 3', :tag_list => 'first-tag, second-tag, third-tag').save!

    box = Box.create!(:owner => @user)
    @block = TagsBlock.create!(:box => box)
  end
  attr_reader :block

  should 'describe itself' do
    assert_not_equal Block.description, TagsBlock.description
  end

  should 'provide a default title' do
    assert_not_equal Block.new.default_title, TagsBlock.new.default_title
  end

  should 'generate links to tags' do
    assert_match /profile\/testinguser\/tags\/first-tag/,  block.content
    assert_match /profile\/testinguser\/tags\/second-tag/, block.content
    assert_match /profile\/testinguser\/tags\/third-tag/,  block.content
  end

  should 'generate links to tags on a environment page' do
    @otheruser = create_user('othertestinguser').person
    @otheruser.articles.build(:name => 'article A', :tag_list => 'other-tag').save!
    @otheruser.articles.build(:name => 'article B', :tag_list => 'other-tag, second-tag').save!
    box = Box.create!(:owner => Environment.default)
    @block = TagsBlock.create!(:box => box)

    assert_match /\/tag\/first-tag" [^>]+"3 items"/,  block.content
    assert_match /\/tag\/second-tag" [^>]+"3 items"/, block.content
    assert_match /\/tag\/third-tag" [^>]+"one item"/, block.content
    assert_match /\/tag\/other-tag" [^>]+"2 items"/,  block.content
  end

  should 'return (none) when no tags to display' do
    block.owner.expects(:article_tags).returns([])
    assert_equal '', block.content
  end

  should 'generate links when profile has own hostname' do
    @user.domains << Domain.new(:name => 'testuser.net'); @user.save!
    assert_match /profile\/testinguser\/tags\/first-tag/, block.content
  end

  should 'order tags alphabetically' do
    assert /\/first-tag".*\/second-tag".*\/third-tag"/m =~  block.content
  end

end
