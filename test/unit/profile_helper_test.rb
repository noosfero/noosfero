require File.dirname(__FILE__) + '/../test_helper'

class ProfileHelperTest < Test::Unit::TestCase

  def setup
    @profile = mock
    @helper = mock
    helper.extend(ProfileHelper)
  end
  attr_reader :profile, :helper

  should 'display info' do
    f1 = 'Field 1'
    v1 = 'value 1'
    f2 = 'Field 2'
    v2 = 'value 2'
    array = [
      [ f1, v1 ],
      [ f2, v2 ]
    ]
    profile.expects(:summary).returns(array)

    helper.expects(:content_tag).returns('').at_least_once

    helper.expects(:_).at_least_once
    helper.expects(:_).with('edit your information').returns('edit your information')
    helper.expects(:button).with(:edit, 'edit your information', :controller => 'profile_editor', :action => 'edit').returns("BUTTON")

    helper.display_profile_info(profile)
  end

  should 'call blocks' do
    myproc = lambda { content_tag('div', 'lalala')  }
    profile.expects(:summary).returns([['f1', myproc ]])
    helper.stubs(:content_tag).returns('')

    helper.expects(:instance_eval).with(myproc)

    helper.expects(:_).at_least_once
    helper.expects(:button).returns('')

    helper.display_profile_info(profile)
  end

end
