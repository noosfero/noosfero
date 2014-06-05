require File.dirname(__FILE__) + '/../test_helper'

class PersonNotifierHelperTest < ActionView::TestCase

  include PersonNotifierHelper

  def setup
    @profile = mock
    @env = Environment.new
  end
  attr_reader :profile, :env

  should 'append top url of environment at image path' do
    profile.expects(:environment).returns(env).at_least_once
    assert_match /src="http:\/\/localhost\/image.png"/, image_tag("/image.png")
  end

  should 'return original path if do not have an environment' do
    profile.expects(:environment).returns(nil).at_least_once
    assert_match /src="\/image.png"/, image_tag("/image.png")
  end

end
