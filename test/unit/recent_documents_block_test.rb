require File.dirname(__FILE__) + '/../test_helper'

class RecentDocumentsBlockTest < Test::Unit::TestCase

  def setup
    @profile = create_user('testinguser').person
    ['first', 'second', 'third', 'fourth', 'fifth'].each do |name|
      @profile.articles << TextArticle.create(:name => name)
    end

    box = Box.create!(:owner => profile)
    @block = RecentDocumentsBlock.create!(:box_id => box.id)

  end
  attr_reader :block, :profile

  should 'describe itself' do
    assert_not_equal Block.description, RecentDocumentsBlock.description
  end

  should 'provide a default title' do
    assert_not_equal Block.new.default_title, RecentDocumentsBlock.new.default_title
  end

  should 'output list with links to recent documents' do
    output = block.content
    
    assert_match /href=.*\/testinguser\/first/, output
    assert_match /href=.*\/testinguser\/second/, output
    assert_match /href=.*\/testinguser\/third/, output
    assert_match /href=.*\/testinguser\/fourth/, output
    assert_match /href=.*\/testinguser\/fifth/, output
  end

  should 'respect the maximum number of items as configured' do
    block.limit = 3

    output = block.content

    assert_match /href=.*\/testinguser\/fifth/, output
    assert_match /href=.*\/testinguser\/fourth/, output
    assert_match /href=.*\/testinguser\/third/, output
    assert_no_match /href=.*\/testinguser\/second/, output
    assert_no_match /href=.*\/testinguser\/first/, output
  end

  should 'not list rss feed articles automatically created' do
    assert_equal 'feed', profile.articles.find_by_path('feed').name
    output = block.content
    assert_match /href=.*\/testinguser\/first/, output
    assert_no_match /href=.*\/testinguser\/feed/, output
  end

  should 'list rss feed articles after update' do
    profile.articles.find_by_path('feed').name = 'chaged name'
    assert profile.articles.find_by_path('feed').save!
    output = block.content
    assert_match /href=.*\/testinguser\/first/, output
    assert_match /href=.*\/testinguser\/feed/, output
  end

  should 'display a link to sitemap with title "All content"' do
    expects(:link_to).with('All content', :controller => 'profile', :action => 'sitemap', :profile => profile.identifier)
    expects(:_).with('All content').returns('All content')

    instance_eval(&(block.footer))
  end

  should 'not display link to sitemap when owner is environment' do
    block = RecentDocumentsBlock.new
    box = mock
    block.expects(:box).returns(box).at_least_once
    box.expects(:owner).returns(Environment.new).at_least_once
    assert_equal nil, block.footer
  end

end
