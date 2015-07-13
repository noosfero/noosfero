require_relative '../test_helper'

require 'comment_controller'

class RelevantContentBlockTest < ActiveSupport::TestCase

  include AuthenticatedTestHelper
  fixtures :users, :environments

  def setup
    @controller = CommentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testinguser').person
    @environment = @profile.environment
  end
  attr_reader :profile, :environment

  should 'have a default title' do
    relevant_content_block = RelevantContentPlugin::RelevantContentBlock.new
    block = Block.new
    assert_not_equal block.default_title, relevant_content_block.default_title
  end

  should 'have a help tooltip' do
    relevant_content_block = RelevantContentPlugin::RelevantContentBlock.new
    block = Block.new
    assert_not_equal "", relevant_content_block.help
  end

  should 'describe itself' do
    assert_not_equal Block.description, RelevantContentPlugin::RelevantContentBlock.description
  end

  should 'is editable' do
    block = RelevantContentPlugin::RelevantContentBlock.new
    assert block.editable?
  end

  should 'expire' do
    assert_equal RelevantContentPlugin::RelevantContentBlock.expire_on, {:environment=>[:article], :profile=>[:article]}
  end

  should 'not crash if vote plugin is not found' do
    box = fast_create(Box, :owner_id => @profile.id, :owner_type => 'Profile')
    block = RelevantContentPlugin::RelevantContentBlock.new(:box => box)

    Environment.any_instance.stubs(:enabled_plugins).returns(['RelevantContent'])
    # When the plugin is disabled from noosfero instance, its constant name is
    # undefined.  To test this case, I have to manually undefine the constant
    # if necessary.
    Object.send(:remove_const, VotePlugin.to_s) if defined? VotePlugin

    assert_nothing_raised do
      block.content
    end
  end

end
