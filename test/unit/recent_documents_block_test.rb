require_relative "../test_helper"

class RecentDocumentsBlockTest < ActiveSupport::TestCase

  def setup
    @articles = []
    @profile = create_user('testinguser').person
    @profile.articles.destroy_all
    ['first', 'second', 'third', 'fourth', 'fifth'].each do |name|
      article = @profile.articles.create!(:name => name)
      @articles << article
    end

    box = Box.new
    box.owner = profile
    box.save!


    @block = RecentDocumentsBlock.new
    @block.box_id = box.id
    @block.save!

  end
  attr_reader :block, :profile, :articles

  should 'describe itself' do
    assert_not_equal Block.description, RecentDocumentsBlock.description
  end

  should 'provide a default title' do
    assert_not_equal Block.new.default_title, RecentDocumentsBlock.new.default_title
  end

  should 'list recent documents' do
    assert_equivalent block.docs, articles
  end

  should 'respect the maximum number of items as configured' do
    block.limit = 3

    list = block.docs

    assert_includes list, articles[4]
    assert_includes list, articles[3]
    assert_includes list, articles[2]
    assert_not_includes list, articles[1]
    assert_not_includes list, articles[0]
  end

  should 'store limit as a number' do
    block.limit = ''
    assert block.limit.is_a?(Fixnum)
  end

  should 'have a non-zero default' do
    block.limit = nil
    assert block.limit > 0
  end

  should 'be able to update display setting' do
    assert @block.update!(:display => 'always')
    @block.reload
    assert_equal 'always', @block.display
  end

  should 'return the max value in the range between zero and limit' do
    block = RecentDocumentsBlock.new
    assert_equal 5, block.get_limit
  end

  should 'return 0 if limit of the block is negative' do
    block = RecentDocumentsBlock.new
    block.limit = -5
    assert_equal 0, block.get_limit
  end
end

require 'boxes_helper'

class RecentDocumentsBlockViewTest < ActionView::TestCase
  include BoxesHelper

  def setup
    @articles = []
    @profile = create_user('testinguser').person
    @profile.articles.destroy_all
    ['first', 'second', 'third', 'fourth', 'fifth'].each do |name|
      article = @profile.articles.create!(:name => name)
      @articles << article
    end

    box = Box.new
    box.owner = profile
    box.save!


    @block = RecentDocumentsBlock.new
    @block.box_id = box.id
    @block.save!

  end
  attr_reader :block, :profile, :articles

  should 'link to documents' do
    articles.each do |a|
      ActionView::Base.any_instance.expects(:link_to).with(a.title, a.url)
    end
    ActionView::Base.any_instance.stubs(:block_title).returns("")
    ActionView::Base.any_instance.stubs(:content_tag).returns("")
    ActionView::Base.any_instance.stubs(:li).returns("")

    render_block_content(block)
  end

  should 'display a link to sitemap with title "All content"' do
    ActionView::Base.any_instance.expects(:link_to).with('All content', :controller => 'profile', :action => 'sitemap', :profile => profile.identifier)
    ActionView::Base.any_instance.expects(:_).with('All content').returns('All content')

    render_block_footer(block)
  end

  should 'not display link to sitemap when owner is environment' do
    block = RecentDocumentsBlock.new
    box = mock
    block.expects(:box).returns(box).at_least_once
    box.expects(:owner).returns(Environment.new).at_least_once
    assert_equal '', render_block_footer(block)
  end
end
