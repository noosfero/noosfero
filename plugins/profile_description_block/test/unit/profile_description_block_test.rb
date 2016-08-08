require 'test_helper'

class ProfileDescriptionBlockTest < ActiveSupport::TestCase
  should 'describe itself' do
    assert_not_equal Block.description, ProfileDescriptionBlock.description
  end
end

require 'boxes_helper'

class ProfileDescriptionBlockViewTest < ActionView::TestCase
  include BoxesHelper

  def setup
    e = Environment.default
    e.enabled_plugins = ['ProfileDescriptionPlugin']
    @person = create_user('test_user').person
    @profile = Profile.create!(:identifier => '1236',
                               :name => 'blabla',
                               :description => "")
  end

  should "show profile description inside block" do
    new_block = ProfileDescriptionBlock.create!

    @profile.boxes.first.blocks << new_block

    block_message = "Description field is empty"
    assert (render_block_content(Block.last).include?(block_message)),
      "description block doesn't show not found description message"

    description = "This is an test"
    @profile.update_attribute("description", description)
    @profile.save!

    assert (render_block_content(Block.last).include?(description)),
      "Description block doesn't show profile description"
  end

  should 'return profile description in api_content when description is present' do
    block = ProfileDescriptionBlock.new
    @person.stubs(:description).returns("This is my description")
    block.stubs(:owner).returns(@person)
    assert_equal "This is my description", block.api_content['description']
  end

  should 'return default message in api_content when description is not present' do
    block = ProfileDescriptionBlock.new
    block.stubs(:owner).returns(@person)
    assert_equal "Description field is empty or not enabled on enviroment", block.api_content['description']
  end
end
