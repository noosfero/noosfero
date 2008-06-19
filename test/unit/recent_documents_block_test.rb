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

end
