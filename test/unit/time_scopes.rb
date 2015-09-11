# encoding: UTF-8
require_relative "../test_helper"

#FIXME Find a way to test with a generic example

class TimeScopesTest < ActiveSupport::TestCase
  should 'fetch profiles older than a specific date' do
    p1 = fast_create(Profile, :created_at => Time.now)
    p2 = fast_create(Profile, :created_at => Time.now - 1.day)
    p3 = fast_create(Profile, :created_at => Time.now - 2.days)
    p4 = fast_create(Profile, :created_at => Time.now - 3.days)

    profiles = Profile.older_than(p2.created_at)

    assert_not_includes profiles, p1
    assert_not_includes profiles, p2
    assert_includes profiles, p3
    assert_includes profiles, p4
  end

  should 'fetch profiles younger than a specific date' do
    p1 = fast_create(Profile, :created_at => Time.now)
    p2 = fast_create(Profile, :created_at => Time.now - 1.day)
    p3 = fast_create(Profile, :created_at => Time.now - 2.days)
    p4 = fast_create(Profile, :created_at => Time.now - 3.days)

    profiles = Profile.younger_than(p3.created_at)

    assert_includes profiles, p1
    assert_includes profiles, p2
    assert_not_includes profiles, p3
    assert_not_includes profiles, p4
  end
end
