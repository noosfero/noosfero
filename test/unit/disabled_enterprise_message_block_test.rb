require_relative "../test_helper"

class DisabledEnterpriseMessageBlockTest < ActiveSupport::TestCase

  should 'provide description' do
    assert_not_equal Block.description, DisabledEnterpriseMessageBlock.description
  end

  include BoxesHelper

  should 'display message for disabled enterprise' do
    environment = Environment.default
    environment.message_for_disabled_enterprise = 'This message is for disabled enterprises'
    environment.save

    enterprise = fast_create(Enterprise, :identifier => 'disabled-enterprise', :environment_id => environment.id)
    enterprise.boxes << Box.new
    enterprise.boxes.first.blocks << DisabledEnterpriseMessageBlock.new
    block = enterprise.boxes.first.blocks.first

    ApplicationHelper.class_eval do
      alias_method :original_profile, :profile
     def profile
       return Enterprise['disabled-enterprise']
     end
    end

    assert_match 'This message is for disabled enterprises', render_block_content(block)

    ApplicationHelper.class_eval do
      alias_method :profile, :original_profile
    end
  end

  should 'not be editable' do
    refute DisabledEnterpriseMessageBlock.new.editable?
  end

end
