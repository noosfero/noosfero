require File.dirname(__FILE__) + '/../test_helper'

class LinkBlockTest < Test::Unit::TestCase
  fixtures :design_blocks

  # Replace this with your real tests.
  def test_content
    l = LinkBlock.new
    assert_kind_of Array, l.content
  end
end
