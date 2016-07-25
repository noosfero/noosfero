require_relative '../test_helper'

class ProfileImagesBlockTest < ActiveSupport::TestCase
  should 'describe itself' do
    assert_not_equal Block.description, ProfileImagesPlugin::ProfileImagesBlock.description
  end

  should 'is editable' do
    block = ProfileImagesPlugin::ProfileImagesBlock.new
    assert block.editable?
  end

  should 'return images' do
    # profile
    # |- image1
    # |- file
    # |- folder1/
    # |--- image2
    # |--- folder2/
    # |------ image3
    profile = create(Profile, name: 'Test')
    image1 = create(UploadedFile, uploaded_data: fixture_file_upload('/files/rails.png', 'image/png'), profile: profile)
    file = fast_create(UploadedFile, profile_id: profile.id)
    folder1 = fast_create(Folder, profile_id: profile.id)
    image2 = create(UploadedFile, uploaded_data: fixture_file_upload('/files/rails.png', 'image/png'), profile: profile, parent: folder1)
    folder2 = fast_create(Folder, parent_id: folder1.id)
    image3 = create(UploadedFile, uploaded_data: fixture_file_upload('/files/rails.png', 'image/png'), profile: profile, parent: folder2)

    block = ProfileImagesPlugin::ProfileImagesBlock.new
    block.stubs(:owner).returns(profile)

    assert_equal [image1, image2, image3].map(&:id), block.images.map(&:id)
  end

  should 'return images with limit' do
    # profile
    # |- image1
    # |- image2
    profile = create(Profile, name: 'Test')
    image1 = create(UploadedFile, uploaded_data: fixture_file_upload('/files/rails.png', 'image/png'), profile: profile)
    image2 = create(UploadedFile, uploaded_data: fixture_file_upload('/files/rails.png', 'image/png'), profile: profile)

    block = ProfileImagesPlugin::ProfileImagesBlock.new
    block.stubs(:owner).returns(profile)
    block.limit = 1

    assert_equal [image1.id], block.images.map(&:id)
  end
end

require 'boxes_helper'

class ProfileImagesBlockViewTest < ActionView::TestCase
  include BoxesHelper

  should 'return images in api_content' do
    # profile
    # |- image1
    # |- image2
    profile = create(Profile, name: 'Test')
    image1 = create(UploadedFile, uploaded_data: fixture_file_upload('/files/rails.png', 'image/png'), profile: profile)
    image2 = create(UploadedFile, uploaded_data: fixture_file_upload('/files/rails.png', 'image/png'), profile: profile)

    block = ProfileImagesPlugin::ProfileImagesBlock.new
    block.stubs(:owner).returns(profile)

    assert_equal [image1.id, image2.id], block.api_content[:images].map{ |a| a[:id] }
  end
end
