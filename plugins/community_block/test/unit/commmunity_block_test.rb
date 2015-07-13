require_relative '../test_helper'

class CommunityBlockTest < ActiveSupport::TestCase

  should "display community block" do
    block = CommunityBlock.new
    self.expects(:render).with(:file => 'community_block', :locals => { :block => block })
    instance_eval(& block.content)
  end

end
