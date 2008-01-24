require File.dirname(__FILE__) + '/../test_helper'

class RecentDocumentsBlockTest < Test::Unit::TestCase

  def setup
    profile = create_user('testinguser').person
    profile.articles.build(:name => 'first').save!
    profile.articles.build(:name => 'second').save!
    profile.articles.build(:name => 'third').save!
    profile.articles.build(:name => 'forth').save!
    profile.articles.build(:name => 'fifth').save!

    box = Box.create!(:owner => profile)
    @block = RecentDocumentsBlock.create!(:box_id => box.id)

  end
  attr_reader :block

  should 'describe itself' do
    assert_not_equal Block.description, RecentDocumentsBlock.description
  end

  should 'output list with links to recent documents' do
    output = block.content
    
    assert_match /href=.*\/testinguser\/first/, output
    assert_match /href=.*\/testinguser\/second/, output
    assert_match /href=.*\/testinguser\/third/, output
    assert_match /href=.*\/testinguser\/forth/, output
    assert_match /href=.*\/testinguser\/fifth/, output
  end

  should 'respect the maximum number of items as configured' do
    block.limit = 3

    output = block.content

    assert_match /href=.*\/testinguser\/first/, output
    assert_match /href=.*\/testinguser\/second/, output
    assert_match /href=.*\/testinguser\/third/, output
    assert_no_match /href=.*\/testinguser\/forth/, output
    assert_no_match /href=.*\/testinguser\/fifth/, output
  end

end
