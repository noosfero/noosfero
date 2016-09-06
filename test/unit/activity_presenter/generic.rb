require_relative "../../test_helper"

class ActivityPresenter::GenericTest < ActiveSupport::TestCase
  should 'accept everything' do
    activity = ActionTracker::Record.new

    activity.stubs(:target).returns(Profile.new)
    assert ActivityPresenter::Generic.accepts?(activity)
    activity.stubs(:target).returns(Article.new)
    assert ActivityPresenter::Generic.accepts?(activity)
    activity.stubs(:target).returns(Scrap.new)
    assert ActivityPresenter::Generic.accepts?(activity)
    activity.stubs(:target).returns(mock)
    assert ActivityPresenter::Generic.accepts?(activity)
  end
end
