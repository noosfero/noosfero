require File.dirname(__FILE__) + '/../test_helper'

class ProfileHelperTest < ActiveSupport::TestCase

  def setup
    @profile = mock
    @helper = mock
    helper.extend(ProfileHelper)
  end
  attr_reader :profile, :helper

  def test_true
    assert true
  end

end
