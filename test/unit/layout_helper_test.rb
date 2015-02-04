require_relative "../test_helper"

class LayoutHelperTest < ActionView::TestCase

  should 'append logged-in class in body when user is logged-in' do
    expects(:logged_in?).returns(true)
    expects(:profile).returns(nil).at_least_once
    assert_includes body_classes.split, 'logged-in'
  end

  should 'not append logged-in class when user is not logged-in' do
    expects(:logged_in?).returns(false)
    expects(:profile).returns(nil).at_least_once
    assert_not_includes body_classes.split, 'logged-in'
  end

end
