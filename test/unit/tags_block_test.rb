require_relative "../test_helper"

class TagsBlockTest < ActiveSupport::TestCase

  def setup
    @user = create_user('testinguser').person
    @user.articles.build(:name => 'article 1', :tag_list => 'first-tag').save!
    @user.articles.build(:name => 'article 2', :tag_list => 'first-tag, second-tag').save!
    @user.articles.build(:name => 'article 3', :tag_list => 'first-tag, second-tag, third-tag').save!

    box = Box.new
    box.owner = @user
    box.save!
    @block = TagsBlock.new
    @block.box = box
    @block.save
  end
  attr_reader :block

  should 'describe itself' do
    assert_not_equal Block.description, TagsBlock.description
  end

  should 'provide a default title' do
    assert_not_equal Block.new.default_title, TagsBlock.new.default_title
  end

  include BoxesHelper

  should 'return the max value in the range between zero and limit' do
    block = TagsBlock.new
    assert_equal 12, block.get_limit
  end

  should '' do
    block = TagsBlock.new
    block.limit = -5
    assert_equal 0, block.get_limit
  end
end

require 'tags_helper'

class TagsBlockViewTest < ActionView::TestCase
  include BoxesHelper

  ActionView::Base.send :include, TagsHelper

  def setup
    @user = create_user('testinguser').person
    @user.articles.build(:name => 'article 1', :tag_list => 'first-tag').save!
    @user.articles.build(:name => 'article 2', :tag_list => 'first-tag, second-tag').save!
    @user.articles.build(:name => 'article 3', :tag_list => 'first-tag, second-tag, third-tag').save!

    box = Box.new
    box.owner = @user
    box.save!
    @block = TagsBlock.new
    @block.box = box
    @block.save
  end
  attr_reader :block

  should 'return (none) when no tags to display' do
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    block.owner.expects(:article_tags).returns([])
    assert_equal "\n\n\n", render_block_content(block)
  end

  should 'order tags alphabetically' do
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    assert /\/first-tag".*\/second-tag".*\/third-tag"/m =~ render_block_content(block)
  end

  should 'generate links to tags' do
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    content = render_block_content(block)
    assert_match /profile\/testinguser\/tags\/first-tag/,  content
    assert_match /profile\/testinguser\/tags\/second-tag/, content
    assert_match /profile\/testinguser\/tags\/third-tag/,  content
  end

  should 'generate links to tags on a environment page' do
    @otheruser = create_user('othertestinguser').person
    @otheruser.articles.build(:name => 'article A', :tag_list => 'other-tag').save!
    @otheruser.articles.build(:name => 'article B', :tag_list => 'other-tag, second-tag').save!
    box = create(Box, :owner => Environment.default)
    @block = create(TagsBlock, :box => box)
    ActionView::Base.any_instance.stubs(:block_title).returns("")

    content = render_block_content(block)
    assert_match /3 items[^>]+\/tag\/first-tag/,  content
    assert_match /3 items[^>]+\/tag\/second-tag/, content
    assert_match /one item[^>]+\/tag\/third-tag/, content
    assert_match /2 item[^>]+\/tag\/other-tag"/,  content
  end


  should 'generate links when profile has own hostname' do
    @user.domains << Domain.new(:name => 'testuser.net'); @user.save!
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    assert_match /profile\/testinguser\/tags\/first-tag/, render_block_content(block)
  end
end
