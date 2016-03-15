require_relative "../test_helper"

class RawHTMLBlockTest < ActiveSupport::TestCase

  should 'describe itself' do
    assert_not_equal Block.description, RawHTMLBlock.description
  end

  should 'store HTML' do
    block = RawHTMLBlock.new(:html => '<strong>HTML!</strong>')
    assert_equal '<strong>HTML!</strong>', block.html
  end

  should 'not filter HTML' do
    html = '<script type="text/javascript">alert("Hello, world")</script>"'
    block = RawHTMLBlock.new(:html => html)
    assert_equal html, block.html
  end

  include BoxesHelper

  should 'return html as content' do
    block = RawHTMLBlock.new(:html => "HTML")
    assert_match /HTML$/, render_block_content(block)
  end

  should 'not be editable for users without permission' do
    environment = Environment.default
    box = Box.new(:owner => environment)
    block = RawHTMLBlock.new(:html => "HTML", :box => box)
    user = create_user('testuser').person
    assert !block.editable?(user)
  end

  should 'be editable for users with permission' do
    environment = Environment.default
    box = Box.new(:owner => environment)
    block = RawHTMLBlock.new(:html => "HTML", :box => box)
    user = create_user_with_permission('testuser', 'edit_raw_html_block', environment)
    assert block.editable?(user)
  end

end
