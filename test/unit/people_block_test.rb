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

  should 'list people' do
    owner = fast_create(Environment)
    block = PeopleBlock.new
    block.expects(:owner).returns(owner).at_least_once
    person1 = fast_create(Person, :environment_id => owner.id)
    person2 = fast_create(Person, :environment_id => owner.id)

    expects(:profile_image_link).with(person1, :minor).returns(person1.name)
    expects(:profile_image_link).with(person2, :minor).returns(person2.name)
    expects(:block_title).with(anything).returns('')

    content = instance_eval(&block.content)

    assert_match(/#{person1.name}/, content)
    assert_match(/#{person2.name}/, content)
  end

  should 'link to browse people' do
    block = PeopleBlock.new
    block.stubs(:owner).returns(Environment.default)

    expects(:_).with('View all').returns('View all people')
    expects(:link_to).with('View all people', :controller => 'browse', :action => 'people')
    instance_eval(&block.footer)
  end

  protected
  include NoosferoTestHelper

end
