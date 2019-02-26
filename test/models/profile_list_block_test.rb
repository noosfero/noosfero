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

  include BoxesHelper

  should 'list people' do
    env = fast_create(Environment)

    person1 = create_user('testperson1', :environment => env).person
    person2 = create_user('testperson2', :environment => env).person
    person3 = create_user('testperson3', :environment => env).person

    block = ProfileListBlock.new
    block.stubs(:owner).returns(env)

    ApplicationHelper.class_eval do
      alias_method :original_profile_image_link, :profile_image_link
      def profile_image_link( profile, size=:portrait, tag='li', extra_info = nil )
        "<#{profile.name}>"
      end

      def theme_option(opt = nil)
        nil
      end

      def user
      end
    end

    content = render_block_content(block)
    assert_match '<testperson1>', content
    assert_match '<testperson2>', content
    assert_match '<testperson3>', content
    ApplicationHelper.class_eval do
      alias_method :profile_image_link, :original_profile_image_link
    end
  end

  should 'not list private profiles' do
    env = fast_create(Environment)
    env.boxes << Box.new
    profile1 = fast_create(Profile, :environment_id => env.id)
    profile2 = fast_create(Profile, :environment_id => env.id, :access => Entitlement::Levels.levels[:self]) # private profile
    block = ProfileListBlock.new
    env.boxes.first.blocks << block
    block.save!

    profiles = block.profile_list
    assert_includes profiles, profile1
    assert_not_includes profiles, profile2
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

  should 'count number of only public profiles' do
    env = fast_create(Environment)
    env.boxes << Box.new
    block = ProfileListBlock.new
    env.boxes.first.blocks << block
    block.save!

    priv_p = fast_create(Person, :environment_id => env.id, :access => Entitlement::Levels.levels[:self])
    pub_p = fast_create(Person, :environment_id => env.id)

    priv_c = fast_create(Community, :access => Entitlement::Levels.levels[:self], :environment_id => env.id)
    pub_c = fast_create(Community, :environment_id => env.id)

    priv_e = fast_create(Enterprise, :access => Entitlement::Levels.levels[:self] , :environment_id => env.id)
    pub_e = fast_create(Enterprise, :environment_id => env.id)

    assert_equal 3, block.profile_count
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

  should 'return available kinds according to base_class' do
    kind1 = Kind.create!(name: 'Kind1', type: 'Person', environment: Environment.default)
    kind2 = Kind.create!(name: 'Kind2', type: 'Community', environment: Environment.default)

    block = ProfileListBlock.new
    block.stubs(:environment).returns(Environment.default)
    block.stubs(:base_class).returns(Person)

    assert_includes block.available_kinds, [kind1.name, kind1.id]
    assert_not_includes block.available_kinds, [kind2.name, kind2.id]
  end

  should 'filter profiles by kind if there is a kind filter' do
    community1 = fast_create(Community)
    community2 = fast_create(Community)
    community3 = fast_create(Community)

    kind = Kind.create!(name: 'Kind', type: 'Community', environment: Environment.default)
    kind.add_profile(community1)
    kind.add_profile(community2)

    block = ProfileListBlock.new
    block.stubs(:owner).returns(Environment.default)
    block.kind_filter = kind.id

    assert_equivalent [community1, community2], block.profile_list
  end

  should 'not filter profiles by kind if there is no kind filter' do
    env = fast_create(Environment)
    community1 = fast_create(Community, environment_id: env.id)
    community2 = fast_create(Community, environment_id: env.id)
    community3 = fast_create(Community, environment_id: env.id)

    kind = Kind.create!(name: 'Kind', type: 'Community', environment: env)
    kind.add_profile(community1)

    block = ProfileListBlock.new
    block.stubs(:owner).returns(env)
    block.kind_filter = nil

    assert_equivalent [community1, community2, community3], block.profile_list
  end

  should 'not filter profiles if there is a filter but the kind does not exist' do
    env = fast_create(Environment)
    community1 = fast_create(Community, environment_id: env.id)
    community2 = fast_create(Community, environment_id: env.id)
    community3 = fast_create(Community, environment_id: env.id)

    block = ProfileListBlock.new
    block.stubs(:owner).returns(env)
    block.kind_filter = "invalid id"
    Kind.expects(:find_by).once.returns(nil)

    assert_equivalent [community1, community2, community3], block.profile_list
  end

  should 'only count number of profiles filtered by kind' do
    community1 = fast_create(Community)
    community2 = fast_create(Community)
    community3 = fast_create(Community)

    kind = Kind.create!(name: 'Kind', type: 'Community', environment: Environment.default)
    kind.add_profile(community1)
    kind.add_profile(community2)

    block = ProfileListBlock.new
    block.stubs(:owner).returns(Environment.default)
    block.kind_filter = kind.id

    assert_equal 2, block.profile_count
  end
end
