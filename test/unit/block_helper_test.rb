require_relative "../test_helper"

class BlockHelperTest < ActiveSupport::TestCase

  include BlockHelper
  include ActionView::Helpers::TagHelper

  should 'escape title html' do
    assert_no_match /<b>/, block_title(unsafe('<b>test</b>'))
    assert_match /&lt;b&gt;test&lt;\/b&gt;/, block_title(unsafe('<b>test</b>'))
  end

  should 'escape subtitle html' do
    assert_no_match /<b>/, block_title('', unsafe('<b>test</b>'))
    assert_match /&lt;b&gt;test&lt;\/b&gt;/, block_title('', unsafe('<b>test</b>'))
  end

  should 'generate tag if title is present' do
    assert_tag_in_string block_title('title', 'subtitle'),
                         tag: 'h3', attributes: { class: 'block-title' }
  end

  should 'generate no tag if title is not present' do
    assert_no_tag_in_string block_title('', 'subtitle'),
                            tag: 'h3', attributes: { class: 'block-title' }
  end

  should 'generate tag if subtitle is present' do
    assert_tag_in_string block_title('title', 'subtitle'),
                         tag: 'h4', attributes: { class: 'block-subtitle' }
  end

  should 'generate no tag if subtitle is not present' do
    assert_no_tag_in_string block_title('title', ''),
                            tag: 'h4', attributes: { class: 'block-subtitle' }
  end

  should 'returns no tag if title and subtitle are empty' do
    assert block_title('', '').blank?
  end
end
