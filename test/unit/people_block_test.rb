require File.dirname(__FILE__) + '/../test_helper'

class PeopleBlockTest < ActiveSupport::TestCase
  
  should 'inherit from ProfileListBlock' do
    assert_kind_of ProfileListBlock, PeopleBlock.new
  end

  should 'declare its default title' do
    assert_not_equal ProfileListBlock.new.default_title, PeopleBlock.new.default_title
  end

  should 'describe itself' do
    assert_not_equal ProfileListBlock.description, PeopleBlock.description
  end

  should 'give help' do
    assert_not_equal ProfileListBlock.new.help, PeopleBlock.new.help
  end

  should 'use its own finder' do
    assert_not_equal ProfileListBlock::Finder, PeopleBlock::Finder
    assert_kind_of PeopleBlock::Finder, PeopleBlock.new.profile_finder
  end

  should 'list people' do
    owner = mock
    owner.expects(:id).returns(99)
    Person.expects(:find).with(:all, :select => 'id', :conditions => { :environment_id => 99}).returns([])
    block = PeopleBlock.new
    block.expects(:owner).returns(owner).at_least_once
    block.content
  end

  should 'link to people directory' do
    block = PeopleBlock.new
    block.stubs(:owner).returns(Environment.default)

    expects(:link_to).with('All people', :controller => 'search', :action => 'assets', :asset => 'people')
    expects(:_).with('All people').returns('All people')
    instance_eval(&block.footer)
  end

end
