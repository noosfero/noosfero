require_relative '../test_helper'

class ProfileActivityTest < ActiveSupport::TestCase

  def setup
    super
  end

  should 'use timestamps from activity' do
    profile = fast_create Person
    target = fast_create Person

    ActionTracker::Record.attr_accessible :created_at, :updated_at
    tracker = ActionTracker::Record.create! verb: :leave_scrap, user: profile, target: target, created_at: Time.now-2.days, updated_at: Time.now-1.day

    pa = ProfileActivity.create! profile: profile, activity: tracker
    assert_equal pa.created_at, pa.activity.created_at
    assert_equal pa.updated_at, pa.activity.updated_at
  end

end
