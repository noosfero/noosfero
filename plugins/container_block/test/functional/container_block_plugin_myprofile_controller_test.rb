require "test_helper"

class ContainerBlockPluginMyprofileControllerTest < ActionDispatch::IntegrationTest
  def setup
    user = create_user("testinguser")
    login_as_rails5(user.login)

    @profile = fast_create(Community)
    @profile.add_admin(user.person)
    @box = Box.create!(owner: @profile)

    @block = ContainerBlockPlugin::ContainerBlock.create!(box_id: @box.id)
    @child1 = Block.create!(box_id: @block.container_box.id)
    @child2 = Block.create!(box_id: @block.container_box.id)
  end

  should "save widths of container block children" do
    post container_block_plugin_myprofile_path(@profile.identifier, :saveWidths, @block), params: { widths: "#{@child1.id},100|#{@child2.id},200" }
    assert_response 200
    assert_equal "Block successfully saved.", @response.body
    @block.reload
    assert_equal 100, @block.child_width(@child1.id)
    assert_equal 200, @block.child_width(@child2.id)
  end
end
