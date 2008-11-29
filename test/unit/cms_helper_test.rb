require File.dirname(__FILE__) + '/../test_helper'

class CmsHelperTest < Test::Unit::TestCase

  include CmsHelper
  include BlogHelper

  should 'show default options for article' do
    result = options_for_article(RssFeed.new)
    assert_match /id="article_published" name="article\[published\]" type="checkbox" value="1"/, result
    assert_match /id="article_accept_comments" name="article\[accept_comments\]" type="checkbox" value="1"/, result
  end

  should 'show custom options for blog' do
    result = options_for_article(Blog.new)
    assert_match /id="article\[published\]" name="article\[published\]" type="hidden" value="1"/, result
    assert_match /id="article\[accept_comments\]" name="article\[accept_comments\]" type="hidden" value="0"/, result
  end

end

module RssFeedHelper
end
