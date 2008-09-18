require File.dirname(__FILE__) + '/../test_helper'

class MyNetworkBlockTest < ActiveSupport::TestCase

  def setup
    @block = MyNetworkBlock.new
    @owner = Person.new(:identifier => 'testuser')
    @block.stubs(:owner).returns(@owner)

    owner.stubs(:environment).returns(Environment.default)
  end
  attr_reader :owner, :block

  should 'provide description' do
    assert_not_equal Block.description, MyNetworkBlock.description
  end

  should 'provide default title' do
    assert_not_equal Block.new.default_title, MyNetworkBlock.new.default_title
  end

  should 'display my-profile' do
    self.expects(:render).with(:file => 'blocks/my_network', :locals => {
        :title => 'My network',
        :owner => owner
    })
    instance_eval(& block.content)
  end

end
