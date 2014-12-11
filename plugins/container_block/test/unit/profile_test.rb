require 'test_helper'

class ProfileTest < ActiveSupport::TestCase

  should 'not lose position values for boxes when the template has a container block' do
    template = fast_create(Profile)
    template.boxes = [Box.new, Box.new]
    template.boxes[0].blocks << ContainerBlockPlugin::ContainerBlock.new
    template.boxes[1].blocks << Block.new
    template.is_template = true
    template.save!

    p = Profile.new
    p.identifier = 'profile-with-template'
    p.name = p.identifier
    p.template = template.reload
    p.save!

    assert_equivalent p.reload.boxes.map(&:position), template.reload.boxes.map(&:position)
  end

  should 'copy contents of a container block that belongs to the template' do
    template = fast_create(Profile)
    template.boxes = [Box.new]
    template.boxes[0].blocks << ContainerBlockPlugin::ContainerBlock.new
    template.is_template = true
    template.save!

    container = template.blocks.first
    container.container_box.blocks << Block.new
    container.container_box.blocks << Block.new
    container.settings[:children_settings] = {}
    container.settings[:children_settings][container.blocks.last.id] = 999
    container.save!

    p = Profile.new
    p.identifier = 'another-profile-with-template'
    p.name = p.identifier
    p.template = template.reload
    p.save!

    container_copy = p.blocks.first
    assert_equal({container_copy.blocks.last.id => 999}, container_copy.children_settings)
    assert_equal container.blocks.size, p.blocks.first.blocks.size
  end

end
