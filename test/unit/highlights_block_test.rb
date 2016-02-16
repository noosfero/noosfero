require_relative "../test_helper"

class HighlightsBlockTest < ActiveSupport::TestCase

  should 'default describe' do
    assert_not_equal Block.description, HighlightsBlock.description
  end

  should 'have field images' do
    h = HighlightsBlock.new
    assert_respond_to h, :images
  end

  should 'have field interval' do
    h = HighlightsBlock.new
    assert_respond_to h, :interval
  end

  should 'have field shuffle' do
    h = HighlightsBlock.new
    assert_respond_to h, :shuffle
  end

  should 'have field navigation' do
    h = HighlightsBlock.new
    assert_respond_to h, :navigation
  end

  should 'default value of images' do
    h = HighlightsBlock.new
    assert_equal [], h.images
  end

  should 'default interval between transitions is 4 seconds' do
    h = HighlightsBlock.new
    assert_equal 4, h.interval
  end

  should 'default value of shuffle' do
    h = HighlightsBlock.new
    assert_equal false, h.shuffle
  end

  should 'default value of navigation' do
    h = HighlightsBlock.new
    assert_equal false, h.navigation
  end

  should 'is editable' do
    h = HighlightsBlock.new
    assert h.editable?
  end

  should 'remove images with blank fields' do
    h = HighlightsBlock.new(:images => [{:image_id => 1, :address => '/address', :position => 1, :title => 'address'}, {:image_id => '', :address => '', :position => '', :title => ''}])
    h.save!
    assert_equal [{:image_id => 1, :address => '/address', :position => 1, :title => 'address', :image_src => nil}], h.images
  end

  should 'be able to update display setting' do
    user = create_user('testinguser').person
    box = fast_create(Box, :owner_id => user.id)
    block = HighlightsBlock.create!(:display => 'never').tap do |b|
      b.box = box
    end
    assert block.update!(:display => 'always')
    block.reload
    assert_equal 'always', block.display
  end

  should 'display highlights block' do
    block = HighlightsBlock.new
    self.expects(:render).with(:file => 'blocks/highlights', :locals => { :block => block})

    instance_eval(& block.content)
  end

  should 'not list non existent image' do
    file = mock()
    UploadedFile.expects(:find).with(1).returns(file)
    file.expects(:public_filename).returns('address')
    UploadedFile.expects(:find).with(0).returns(nil)
    block = HighlightsBlock.new(:images => [{:image_id => 1, :address => '/address', :position => 1, :title => 'address'}, {:image_id => '', :address => 'some', :position => '2', :title => 'Some'}])
    block.save!
    block.reload
    assert_equal 2, block.images.count
    assert_equal [{:image_id => 1, :address => '/address', :position => 1, :title => 'address', :image_src => 'address'}], block.featured_images
  end

  should 'list images in order' do
    f1 = mock()
    f1.expects(:public_filename).returns('address')
    UploadedFile.expects(:find).with(1).returns(f1)
    f2 = mock()
    f2.expects(:public_filename).returns('address')
    UploadedFile.expects(:find).with(2).returns(f2)
    f3 = mock()
    f3.expects(:public_filename).returns('address')
    UploadedFile.expects(:find).with(3).returns(f3)
    block = HighlightsBlock.new
    i1 = {:image_id => 1, :address => '/address', :position => 3, :title => 'address'}
    i2 = {:image_id => 2, :address => '/address', :position => 1, :title => 'address'}
    i3 = {:image_id => 3, :address => '/address', :position => 2, :title => 'address'}
    block.images = [i1,i2,i3]
    block.save!
    block.reload
    assert_equal [i1,i2,i3], block.images
    assert_equal [i2,i3,i1], block.featured_images
  end

  should 'list images randomically' do
    block = HighlightsBlock.new
    block.shuffle = true

    images = []
    block.expects(:get_images).returns(images)
    images.expects(:shuffle).returns(images)

    block.featured_images
  end

  should 'return correct sub-dir address' do
    Noosfero.stubs(:root).returns("/social")
    f1 = mock()
    f1.expects(:public_filename).returns('address')
    UploadedFile.expects(:find).with(1).returns(f1)
    block = HighlightsBlock.new
    i1 = {:image_id => 1, :address => '/address', :position => 3, :title => 'address'}
    block.images = [i1]
    block.save!
    block.reload
    assert_equal block.images.first[:address], "/social/address"
  end

  should 'not duplicate sub-dir address before save' do
    Noosfero.stubs(:root).returns("/social")
    f1 = mock()
    f1.expects(:public_filename).returns('address')
    UploadedFile.expects(:find).with(1).returns(f1)
    block = HighlightsBlock.new
    i1 = {:image_id => 1, :address => '/social/address', :position => 3, :title => 'address'}
    block.images = [i1]
    block.save!
    block.reload
    assert_equal block.images.first[:address], "/social/address"
  end

  should 'display images with subdir src' do
    Noosfero.stubs(:root).returns("/social")
    f1 = mock()
    f1.expects(:public_filename).returns('/img_address')
    UploadedFile.expects(:find).with(1).returns(f1)
    block = HighlightsBlock.new
    i1 = {:image_id => 1, :address => '/address'}
    block.images = [i1]
    block.save!

    assert_tag_in_string instance_eval(& block.content), :tag => 'img', :attributes => { :src => "/social/img_address" }
  end

  [Environment, Profile].each do |klass|
    should "choose between owner galleries when owner is #{klass.name}" do
      owner = fast_create(klass)

      block = HighlightsBlock.new
      block.stubs(:owner).returns(owner)

      assert_equal [], block.folder_choices
    end
  end

end
