require File.dirname(__FILE__) + '/../test_helper'

class DisabledEnterpriseMessageBlockTest < ActiveSupport::TestCase

  should 'provide description' do
    assert_not_equal Block.description, DisabledEnterpriseMessageBlock.description
  end

  should 'display message for disabled enterprise' do
    e = Environment.default
    e.expects(:message_for_disabled_enterprise).returns('This message is for disabled enterprises')
    block = DisabledEnterpriseMessageBlock.new
    p = Profile.new
    block.expects(:owner).returns(p)
    p.expects(:environment).returns(e)

    expects(:render).with(:file => 'blocks/disabled_enterprise_message', :locals => { :message => 'This message is for disabled enterprises'})
    instance_eval(&block.content)
  end

  should 'display nothing if environment has no message' do
    e = fast_create(Environment)
    block = DisabledEnterpriseMessageBlock.new
    p = Profile.new
    block.expects(:owner).returns(p)
    p.expects(:environment).returns(e)

    expects(:render).with(:file => 'blocks/disabled_enterprise_message', :locals => { :message => ''})
    instance_eval(&block.content)
  end

  should 'not be editable' do
    assert !DisabledEnterpriseMessageBlock.new.editable?
  end

end
