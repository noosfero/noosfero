require_relative "../test_helper"
require 'tag'

class UserTest < ActiveSupport::TestCase

  def test_find_without_pendings
    tag1 = Tag.create(name: 'pending_tag', pending: true)
    tag2 = Tag.create(name: 'approved_tag', pending: false)
    assert_nothing_raised {Tag.find(tag2.id)}
    assert_raise(ActiveRecord::RecordNotFound) {Tag.find(tag1.id)}
  end

  def test_find_pendings
    tag1 = Tag.create(name: 'pending_tag', pending: true)
    tag2 = Tag.create(name: 'approved_tag', pending: false)
    assert Tag.find_pendings.include?(tag1)
    assert (not Tag.find_pendings.include?(tag2))
  end

  def test_parent_candidates
    tag1 = Tag.create(name: 'parent_tag')
    tag2 = Tag.create(name: 'child_tag', parent_id: tag1.id)
    assert ( not tag1.parent_candidates.include?(tag2) )
    assert tag2.parent_candidates.include?(tag1)
  end

  def test_descendents
    tag1 = Tag.create(name: 'parent_tag')
    tag2 = Tag.create(name: 'child_tag', parent_id: tag1.id)
    tag3 = Tag.create(name: 'grand_tag', parent_id: tag2.id)
    assert (not tag2.descendents.include?(tag1))
    assert (not tag1.descendents.include?(tag1))
    assert tag1.descendents.include?(tag2)
    assert tag1.descendents.include?(tag3)
  end

end
