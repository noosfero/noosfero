require 'test_helper'

class GoogleAnalyticsPluginTest < ActiveSupport::TestCase

  def setup
    @plugin = GoogleAnalyticsPlugin.new
    @context = mock()
    @profile = mock()
    @profile.stubs(:data).returns({:google_analytics_profile_id => 10})
    @profile.stubs(:google_analytics_profile_id).returns(10)
    @plugin.context = @context
    @context.stubs(:profile).returns(@profile)
  end

  should 'return profile_id nil if not in profile context' do
    @context.stubs(:profile).returns(nil)
    assert_nil @plugin.profile_id
  end

  should 'return profile_id if in profile context' do
    assert_not_nil @plugin.profile_id
    assert_equal 10, @plugin.profile_id
  end

  should 'add content at HTML head if profile_id not nil' do
    @plugin.expects(:expanded_template).once.returns('content')
    assert_equal 'content', @plugin.head_ending
  end

  should 'extends Profile with attr google_analytics_profile_id' do
    assert_respond_to Profile.new, :google_analytics_profile_id
  end
end
