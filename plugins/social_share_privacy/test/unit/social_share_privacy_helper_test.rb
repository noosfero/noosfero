require 'test_helper'

class SocialSharePrivacyPluginHelperTest < ActiveSupport::TestCase

  include SocialSharePrivacyPluginHelper

  should 'list social networks provided' do
    assert_equal ['buffer', 'facebook', 'gplus', 'mail', 'stumbleupon', 'xing', 'delicious', 'fbshare', 'hackernews', 'pinterest', 'tumblr', 'disqus', 'flattr', 'linkedin', 'reddit', 'twitter'].sort, social_share_privacy_networks.sort
  end

end
