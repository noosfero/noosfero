require_relative "../test_helper"

class ProfileListBlockTest < ActiveSupport::TestCase

  include ActionView::Helpers::TagHelper

  should 'describe itself' do
    assert_not_equal Block.description, ProfileListBlock.description
  end

  should 'provide a default title' do
    assert_not_equal Block.new.default_title, ProfileListBlock.new.default_title
  end

  should 'accept a limit of people to be displayed (and default to 6)' do
    block = ProfileListBlock.new
    assert_equal 6, block.limit

    block.limit = 20
    assert_equal 20, block.limit
  end

  should 'list people' do
    env = fast_create(Environment)

    person1 = create_user('testperson1', :environment => env).person
    person2 = create_user('testperson2', :environment => env).person
    person3 = create_user('testperson3', :environment => env).person

    block = ProfileListBlock.new
    block.stubs(:owner).returns(env)

    self.expects(:profile_image_link).with(person1, :minor).once
    self.expects(:profile_image_link).with(person2, :minor).once
    self.expects(:profile_image_link).with(person3, :minor).once

    self.stubs(:tag).returns('<div></div>')
    self.expects(:content_tag).returns('<div></div>').at_least_once
    self.expects(:block_title).returns('block title').at_least_once

    assert_kind_of String, instance_eval(&block.content)
  end

  should 'list private profiles' do
    env = fast_create(Environment)
    env.boxes << Box.new
    profile1 = fast_create(Profile, :environment_id => env.id)
    profile2 = fast_create(Profile, :environment_id => env.id, :public_profile => false) # private profile
    block = ProfileListBlock.new
    env.boxes.first.blocks << block
    block.save!

    profiles = block.profiles
    assert_includes profiles, profile1
    assert_includes profiles, profile2
  end

  should 'not list invisible profiles' do
    env = fast_create(Environment)
    env.boxes << Box.new
    profile1 = fast_create(Profile, :environment_id => env.id)
    profile2 = fast_create(Profile, :environment_id => env.id, :visible => false) # not visible profile
    block = ProfileListBlock.new
    env.boxes.first.blocks << block
    block.save!

    profiles = block.profile_list
    assert_includes profiles, profile1
    assert_not_includes profiles, profile2
  end

  should 'provide view_title' do
    env = fast_create(Environment)
    env.boxes << Box.new
    block = ProfileListBlock.new(:title => 'Title from block')
    env.boxes.first.blocks << block
    block.save!
    assert_equal 'Title from block', block.view_title
  end
  
  should 'provide view title with variables' do
    env = fast_create(Environment)
    env.boxes << Box.new
    block = ProfileListBlock.new(:title => '{#} members')
    env.boxes.first.blocks << block
    block.save!
    assert_equal '0 members', block.view_title
  end

  should 'count number of public and private profiles' do
    env = fast_create(Environment)
    env.boxes << Box.new
    block = ProfileListBlock.new
    env.boxes.first.blocks << block
    block.save!

    priv_p = fast_create(Person, :environment_id => env.id, :public_profile => false)
    pub_p = fast_create(Person, :environment_id => env.id, :public_profile => true)

    priv_c = fast_create(Community, :public_profile => false, :environment_id => env.id)
    pub_c = fast_create(Community, :public_profile => true , :environment_id => env.id)

    priv_e = fast_create(Enterprise, :public_profile => false , :environment_id => env.id)
    pub_e = fast_create(Enterprise, :public_profile => true , :environment_id => env.id)

    assert_equal 6, block.profile_count
  end

  should 'only count number of visible profiles' do
    env = fast_create(Environment)
    env.boxes << Box.new
    block = ProfileListBlock.new
    env.boxes.first.blocks << block
    block.save!

    priv_p = fast_create(Person, :environment_id => env.id, :visible => false)
    pub_p = fast_create(Person, :environment_id => env.id, :visible => true)

    priv_c = fast_create(Community, :visible => false, :environment_id => env.id)
    pub_c = fast_create(Community, :visible => true , :environment_id => env.id)

    priv_e = fast_create(Enterprise, :visible => false , :environment_id => env.id)
    pub_e = fast_create(Enterprise, :visible => true , :environment_id => env.id)

    assert_equal 3, block.profile_count
  end

  should 'respect limit when listing profiles' do
    env = fast_create(Environment)
    p1 = fast_create(Person, :environment_id => env.id)
    p2 = fast_create(Person, :environment_id => env.id)
    p3 = fast_create(Person, :environment_id => env.id)
    p4 = fast_create(Person, :environment_id => env.id)

    block = ProfileListBlock.new(:limit => 3)
    block.stubs(:owner).returns(env)

    assert_equal 3, block.profile_list.size
  end

  should 'list random profiles' do
    env = fast_create(Environment)
    6.times.each do
      fast_create(Person, :environment_id => env.id)
    end

    block = ProfileListBlock.new
    block.stubs(:owner).returns(env)

    assert_not_equal block.profile_list.map(&:id), block.profile_list.map(&:id)
  end

  should 'prioritize profiles with image if this option is turned on' do
    env = fast_create(Environment)
    img1 = create(Image, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    p1 = fast_create(Person, :environment_id => env.id, :image_id => img1.id)
    img2 = create(Image, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    p2 = fast_create(Person, :environment_id => env.id, :image_id => img2.id)

    p_without_image = fast_create(Person, :environment_id => env.id)

    block = ProfileListBlock.new(:limit => 2)
    block.stubs(:owner).returns(env)
    block.stubs(:prioritize_profiles_with_image).returns(true)

    assert_not_includes block.profile_list[0..1], p_without_image
  end

  should 'list profiles without image only if profiles with image arent enought' do
    env = fast_create(Environment)
    img1 = create(Image, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    p1 = fast_create(Person, :environment_id => env.id, :image_id => img1.id)
    img2 = create(Image, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    p2 = fast_create(Person, :environment_id => env.id, :image_id => img2.id)
    p_without_image = fast_create(Person, :environment_id => env.id)
    block = ProfileListBlock.new
    block.stubs(:owner).returns(env)
    block.stubs(:prioritize_profiles_with_image).returns(true)

    block.limit = 2
    assert_not_includes block.profile_list, p_without_image

    block.limit = 3
    assert_includes block.profile_list, p_without_image
  end

  should 'list profile with image among profiles without image' do
    env = fast_create(Environment)
    5.times do |n|
      fast_create(Person, :environment_id => env.id)
    end
    img = create(Image, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    with_image = fast_create(Person, :environment_id => env.id, :image_id => img.id)
    block = ProfileListBlock.new(:limit => 3)
    block.stubs(:prioritize_profiles_with_image).returns(true)
    block.stubs(:owner).returns(env)
    assert_includes block.profile_list, with_image
  end

  should 'not prioritize profiles with image if this option is turned off' do
    env = fast_create(Environment)
    img = create(Image, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    with_image = fast_create(Person, :environment_id => env.id, :updated_at => DateTime.now, :image_id => img.id)
    5.times do |n|
      fast_create(Person, :environment_id => env.id, :updated_at => DateTime.now + 1.day)
    end

    block = ProfileListBlock.new(:limit => 3)
    block.stubs(:owner).returns(env)
    block.stubs(:prioritize_profiles_with_image).returns(false)

    assert_not_includes block.profile_list, with_image
  end

  should 'prioritize profiles with image by default' do
    assert ProfileListBlock.new.prioritize_profiles_with_image
  end

  should 'return the max value in the range between zero and limit' do
    block = ProfileListBlock.new
    assert_equal 6, block.get_limit
  end

  should 'return 0 if limit of the block is negative' do
    block = ProfileListBlock.new
    block.limit = -5
    assert_equal 0, block.get_limit
  end
end
