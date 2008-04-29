require File.dirname(__FILE__) + '/../test_helper'

class ProfileHelperTest < Test::Unit::TestCase

  def setup
    @profile = mock
    @helper = mock
    helper.extend(ProfileHelper)
  end
  attr_reader :profile, :helper

  def test_should_ignore_nil
    profile.expects(:info).returns(nil)

    helper.expects(:content_tag)
    helper.expects(:_)

    helper.display_profile_info(profile)
  end

  def test_should_display_info
    f1 = 'Field 1'
    v1 = 'value 1'
    f2 = 'Field 2'
    v2 = 'value 2'
    array = [
      [ f1, v1 ],
      [ f2, v2 ]
    ]
    info = mock
    info.expects(:summary).returns(array)
    profile.stubs(:info).returns(info)

    helper.expects(:content_tag).with('th', f1).returns(f1)
    helper.expects(:content_tag).with('td', v1).returns(v1)
    helper.expects(:content_tag).with('tr', f1 + v1).returns('r1')
    helper.expects(:content_tag).with('th', f2).returns(f2)
    helper.expects(:content_tag).with('td', v2).returns(v2)
    helper.expects(:content_tag).with('tr', f2 + v2).returns('r2')
    helper.expects(:content_tag).with('table', "r1\nr2\n", :class => 'profile_info' ).returns('final')

    assert_equal 'final', helper.display_profile_info(profile)
  end

  def test_should_call_blocks
    myproc = lambda { content_tag('div', 'lalala')  }
    info = mock
    info.expects(:summary).returns([['f1', myproc ]])
    profile.stubs(:info).returns(info)
    helper.stubs(:content_tag).returns('')

    helper.expects(:instance_eval).with(myproc)

    helper.expects(:_)
    helper.expects(:button).returns('')

    helper.display_profile_info(profile)
  end

end
