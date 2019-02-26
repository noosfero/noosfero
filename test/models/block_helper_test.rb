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

  should 'add "empty" class to blank subtitles tag' do
    assert_match "block-subtitle empty", block_title('', '')
  end
end
