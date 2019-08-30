require_relative "../test_helper"

class HighlightsBlockTest < ActiveSupport::TestCase
  should "default describe" do
    assert_not_equal Block.description, HighlightsBlock.description
  end

  should "have field images" do
    h = HighlightsBlock.new
    assert_respond_to h, :block_images
  end

  should "have field interval" do
    h = HighlightsBlock.new
    assert_respond_to h, :interval
  end

  should "have field shuffle" do
    h = HighlightsBlock.new
    assert_respond_to h, :shuffle
  end

  should "have field navigation" do
    h = HighlightsBlock.new
    assert_respond_to h, :navigation
  end

  should "default value of images" do
    h = HighlightsBlock.new
    assert_equal [], h.block_images
  end

  should "default interval between transitions is 4 seconds" do
    h = HighlightsBlock.new
    assert_equal 4, h.interval
  end

  should "default value of shuffle" do
    h = HighlightsBlock.new
    assert_equal false, h.shuffle
  end

  should "default value of navigation" do
    h = HighlightsBlock.new
    assert_equal false, h.navigation
  end

  should "is editable" do
    h = HighlightsBlock.new
    assert h.editable?
  end

  should "remove images with blank fields" do
    h = HighlightsBlock.new(block_images: [{ image_id: 1, address: "/address", position: 1, title: "address" },
                                           { image_id: "", address: "", position: "", title: "" }])
    h.save!
    assert_equal [{ image_id: 1, address: "/address", position: 1, title: "address", new_window: false }],
                 h.block_images
  end

  should "replace 1 and 0 by true and false in new_window attribute" do
    image1 = { image_id: 1, address: "/address-1", position: 1, title: "address-1", new_window: "0" }
    image2 = { image_id: 2, address: "/address-2", position: 2, title: "address-2", new_window: "1" }
    h = HighlightsBlock.new(block_images: [image1, image2])
    h.save!
    image1[:new_window] = false
    image2[:new_window] = true

    assert_equivalent [image1, image2], h.block_images
  end

  should "be able to update display setting" do
    user = create_user("testinguser").person
    box = fast_create(Box, owner_id: user.id)
    block = HighlightsBlock.create!(display: "never").tap do |b|
      b.box = box
    end
    assert block.update!(display: "always")
    block.reload
    assert_equal "always", block.display
  end

  include BoxesHelper

  should "display highlights block" do
    block = HighlightsBlock.new
    self.expects(:render).with(template: "blocks/highlights", locals: { block: block })

    render_block_content(block)
  end

  should "not list non existent image" do
    file = mock()
    UploadedFile.expects(:find_by).with(id: 1).returns(file)
    file.expects(:public_filename).returns("address")
    UploadedFile.expects(:find_by).with(id: 0).returns(nil)
    block = HighlightsBlock.new(block_images: [{ image_id: 1, address: "/address", position: 1, title: "address" }, { image_id: "", address: "some", position: "2", title: "Some" }])
    block.save!
    block.reload
    assert_equal 2, block.block_images.count
    assert_equal [{ image_id: 1, address: "/address", position: 1, title: "address", new_window: false, image_src: "address" }], block.featured_images
  end

  should "list images in order" do
    f1 = mock()
    f1.expects(:public_filename).returns("address")
    UploadedFile.expects(:find_by).with(id: 1).returns(f1)
    f2 = mock()
    f2.expects(:public_filename).returns("address")
    UploadedFile.expects(:find_by).with(id: 2).returns(f2)
    f3 = mock()
    f3.expects(:public_filename).returns("address")
    UploadedFile.expects(:find_by).with(id: 3).returns(f3)
    block = HighlightsBlock.new
    i1 = { image_id: 1, address: "/address", position: 3, title: "address" }
    i2 = { image_id: 2, address: "/address", position: 1, title: "address" }
    i3 = { image_id: 3, address: "/address", position: 2, title: "address" }
    block.block_images = [i1, i2, i3]
    block.save!
    block.reload
    assert_equal [i1, i2, i3], block.block_images
    assert_equal [i2, i3, i1], block.featured_images
  end

  should "list images randomically" do
    block = HighlightsBlock.new
    block.shuffle = true

    images = []
    block.expects(:get_images).returns(images)
    images.expects(:shuffle).returns(images)

    block.featured_images
  end

  should "return correct sub-dir address" do
    Noosfero.stubs(:root).returns("/social")
    f1 = mock()
    f1.expects(:public_filename).returns("address")
    UploadedFile.expects(:find_by).with(id: 1).returns(f1)
    block = HighlightsBlock.new
    i1 = { image_id: 1, address: "/address", position: 3, title: "address" }
    block.block_images = [i1]
    block.save!
    block.reload
    assert_equal block.block_images.first[:address], "/social/address"
  end

  should "not duplicate sub-dir address before save" do
    Noosfero.stubs(:root).returns("/social")
    f1 = mock()
    f1.expects(:public_filename).returns("address")
    UploadedFile.expects(:find_by).with(id: 1).returns(f1)
    block = HighlightsBlock.new
    i1 = { image_id: 1, address: "/social/address", position: 3, title: "address" }
    block.block_images = [i1]
    block.save!
    block.reload
    assert_equal block.block_images.first[:address], "/social/address"
  end

  should "display images with subdir src" do
    Noosfero.stubs(:root).returns("/social")
    f1 = mock()
    f1.expects(:public_filename).returns("/img_address")
    UploadedFile.expects(:find_by).with(id: 1).returns(f1)
    block = HighlightsBlock.new
    i1 = { image_id: 1, address: "/address" }
    block.block_images = [i1]
    block.save!

    assert_tag_in_string render_block_content(block), tag: "div", attributes: { class: "highlights-img1", style: "background-image:url(/social/img_address)" }
    assert_tag_in_string render_block_content(block), tag: "div", attributes: { class: "highlights-img2", style: "background-image:url(/social/img_address)" }
  end

  [Environment, Profile].each do |klass|
    should "choose between owner galleries when owner is #{klass.name}" do
      owner = fast_create(klass)

      block = HighlightsBlock.new
      block.stubs(:owner).returns(owner)

      assert_equal [], block.folder_choices
    end
  end

  should "remove unused images when save" do
    block = create(HighlightsBlock, images_builder: [{
                     uploaded_data: fixture_file_upload("/files/rails.png", "image/png")
                   }])
    assert_equal 1, block.images.size
    block.save!
    block.reload
    assert_equal 0, block.images.size
  end

  should "return slides in api_content" do
    block = create(HighlightsBlock, images_builder: [{
                     uploaded_data: fixture_file_upload("/files/rails.png", "image/png")
                   }])
    block.block_images = [{ image_id: block.images.first.id }]
    assert_equal 1, block.api_content[:slides].size
  end

  should "not return image_id for images that does not exists anymore" do
    block = create(HighlightsBlock, images_builder: [{
                     uploaded_data: fixture_file_upload("/files/rails.png", "image/png")
                   }])
    block.block_images = [{ image_id: block.images.first.id }]
    block.images.first.destroy
    assert_nil block.api_content[:slides].first[:image_id]
  end

  should "keep image_src for images that was not found as uploaded_file" do
    block = create(HighlightsBlock, images_builder: [{
                     uploaded_data: fixture_file_upload("/files/rails.png", "image/png")
                   }])
    block.block_images = [{ image_id: block.images.first.id, image_src: block.images.first.public_filename }]
    block.save!
    assert block.block_images.first[:image_src].present?
  end
end
