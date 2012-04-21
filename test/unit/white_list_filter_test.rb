require File.dirname(__FILE__) + '/../test_helper'

class WhiteListFilterTest < ActiveSupport::TestCase

  include WhiteListFilter

  def environment
    @environment ||= Environment.default
  end

  should 'remove iframe if it is not from a trusted site' do
    content = "<iframe src='http://anything/videos.ogg'></iframe>"
    assert_equal "", check_iframe_on_content(content, environment.trusted_sites_for_iframe)
  end

  should 'not mess with <iframe and </iframe if it is from itheora by default' do
    assert_includes Environment.default.trusted_sites_for_iframe, 'itheora.org'
    content = "<iframe src='http://itheora.org/demo/index.php?v=example.ogv'></iframe>"
    assert_equal "<iframe src='http://itheora.org/demo/index.php?v=example.ogv'></iframe>", check_iframe_on_content(content, environment.trusted_sites_for_iframe)
  end

  should 'allow iframe if it is from stream.softwarelivre.org by default' do
    assert_includes Environment.default.trusted_sites_for_iframe, 'stream.softwarelivre.org'
    content = "<iframe src='http://stream.softwarelivre.org/fisl10/sites/default/files/videos.ogg'></iframe>"
    assert_equal "<iframe src='http://stream.softwarelivre.org/fisl10/sites/default/files/videos.ogg'></iframe>", check_iframe_on_content(content, environment.trusted_sites_for_iframe)
  end

  should 'allow iframe if it is from tv.softwarelivre.org by default' do
    assert_includes Environment.default.trusted_sites_for_iframe, 'tv.softwarelivre.org'
    content = "<iframe id='player-base' src='http://tv.softwarelivre.org/embed/1170' width='482' height='406' align='right' frameborder='0' scrolling='no'></iframe>"
    assert_equal "<iframe id='player-base' src='http://tv.softwarelivre.org/embed/1170' width='482' height='406' align='right' frameborder='0' scrolling='no'></iframe>", check_iframe_on_content(content, environment.trusted_sites_for_iframe)
  end

  should 'allow iframe if it is from a trusted site' do
    env = Environment.default
    env.trusted_sites_for_iframe = ['avideosite.com']
    env.save
    assert_includes Environment.default.trusted_sites_for_iframe, 'avideosite.com'
    content = "<iframe src='http://avideosite.com/videos.ogg'></iframe>"
    assert_equal "<iframe src='http://avideosite.com/videos.ogg'></iframe>", check_iframe_on_content(content, environment.trusted_sites_for_iframe)
  end

  should 'remove only the iframe from untrusted site' do
    content = "<iframe src='http://stream.softwarelivre.org/videos.ogg'></iframe><iframe src='http://untrusted_site.com/videos.ogg'></iframe>"
    assert_equal "<iframe src='http://stream.softwarelivre.org/videos.ogg'></iframe>", check_iframe_on_content(content, environment.trusted_sites_for_iframe)
  end

  should 'remove iframe if it has 2 or more src' do
    assert_includes Environment.default.trusted_sites_for_iframe, 'itheora.org'

    content = "<iframe src='http://itheora.org/videos.ogg' src='http://untrusted_site.com/videos.ogg'></iframe>"
    assert_equal '', check_iframe_on_content(content, environment.trusted_sites_for_iframe)
  end
end
