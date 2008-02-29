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

  should 'not list rss feed articles' do
    profile.articles << RssFeed.create(:name => 'sixth')
    profile.save!

    output = block.content

    assert_match /href=.*\/testinguser\/first/, output
    assert_no_match /href=.*\/testinguser\/sixth/, output
  end

end
