require 'test_helper'

class UrlHelperTest < ActionView::TestCase

  include UrlHelper

  def setup
  end

  should 'preserve override_user if present' do
    params[:override_user] = 1
    assert_equal default_url_options[:override_user], params[:override_user]
  end

end
