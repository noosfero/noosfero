# encoding: UTF-8
require_relative "../test_helper"

class ProfileImageHelperTest < ActionView::TestCase
  include Noosfero::Gravatar
  include ThemeLoaderHelper
  include ProfileImageHelper

  should "Extra info with hash" do
    @plugins = mock
    @plugins.stubs(:dispatch_first).returns(false)
    env = Environment.default
    stubs(:environment).returns(env)
    stubs(:profile).returns(profile)
    profile = fast_create(Person, :environment_id => env.id)
    info = {:value =>_('New'), :class => 'new-profile'}
    html = profile_image_link(profile, size=:portrait, tag='li', extra_info = info)
    assert_tag_in_string html, :tag => 'span', :attributes => { :class => 'profile-image new-profile' }
    assert_tag_in_string html, :tag => 'span', :attributes => { :class => 'extra_info new-profile' }, :content => 'New'
  end

  should "Extra info without hash" do
    @plugins = mock
    @plugins.stubs(:dispatch_first).returns(false)
    env = Environment.default
    stubs(:environment).returns(env)
    stubs(:profile).returns(profile)
    profile = fast_create(Person, :environment_id => env.id)
    info = 'new'
    html = profile_image_link(profile, size=:portrait, tag='li', extra_info = info)
    assert_tag_in_string html, :tag => 'span', :attributes => { :class => 'extra_info' }, :content => 'new'
  end

  should 'return nil when :show_balloon_with_profile_links_when_clicked is not enabled in environment' do
    env = Environment.default
    env.stubs(:enabled?).with(:show_balloon_with_profile_links_when_clicked).returns(false)
    stubs(:environment).returns(env)
    profile = Profile.new
    assert_nil links_for_balloon(profile)
  end

  should 'return ordered list of links to balloon to Person' do
    env = Environment.default
    env.stubs(:enabled?).with(:show_balloon_with_profile_links_when_clicked).returns(true)
    stubs(:environment).returns(env)
    person = Person.new identifier: 'person'
    person.stubs(:url).returns('url for person')
    person.stubs(:public_profile_url).returns('url for person')
    links = links_for_balloon(person)
    assert_equal ['Wall', 'Friends', 'Communities', 'Send an e-mail', 'Add'], links.map{|i| i.keys.first}
  end

  should 'return ordered list of links to balloon to Community' do
    env = Environment.default
    env.stubs(:enabled?).with(:show_balloon_with_profile_links_when_clicked).returns(true)
    stubs(:environment).returns(env)
    community = Community.new identifier: 'comm'
    community.stubs(:url).returns('url for community')
    community.stubs(:public_profile_url).returns('url for community')
    links = links_for_balloon(community)
    assert_equal ['Wall', 'Members', 'Agenda', 'Join', 'Leave community', 'Send an e-mail'], links.map{|i| i.keys.first}
  end

  should 'return ordered list of links to balloon to Enterprise' do
    env = Environment.default
    env.stubs(:enabled?).with(:show_balloon_with_profile_links_when_clicked).returns(true)
    stubs(:environment).returns(env)
    enterprise = Enterprise.new identifier: 'coop'
    enterprise.stubs(:url).returns('url for enterprise')
    enterprise.stubs(:public_profile_url).returns('url for enterprise')
    stubs(:catalog_path)
    links = links_for_balloon(enterprise)
    assert_equal ['Products', 'Members', 'Agenda', 'Send an e-mail'], links.map{|i| i.keys.first}
  end

  should 'not return mime type of profile icon if not requested' do
    stubs(:profile).returns(Person.new)
    stubs(:current_theme).returns('default')

    filename, mime = profile_icon(Person.new, :thumb)
    assert_not_nil filename
    assert_nil mime
  end

  should 'return mime type of profile icon' do
    stubs(:profile).returns(Person.new)
    stubs(:current_theme).returns('default')

    filename, mime = profile_icon(Person.new, :thumb, true)
    assert_not_nil filename
    assert_not_nil mime
  end

  should 'provide sex icon for males' do
    stubs(:environment).returns(Environment.default)
    expects(:content_tag).with(anything, 'male').returns('MALE!!')
    expects(:content_tag).with(anything, 'MALE!!', is_a(Hash)).returns("FINAL")
    assert_equal "FINAL", profile_sex_icon(build(Person, :sex => 'male'))
  end

  should 'provide sex icon for females' do
    stubs(:environment).returns(Environment.default)
    expects(:content_tag).with(anything, 'female').returns('FEMALE!!')
    expects(:content_tag).with(anything, 'FEMALE!!', is_a(Hash)).returns("FINAL")
    assert_equal "FINAL", profile_sex_icon(build(Person, :sex => 'female'))
  end

  should 'provide undef sex icon' do
    stubs(:environment).returns(Environment.default)
    expects(:content_tag).with(anything, 'undef').returns('UNDEF!!')
    expects(:content_tag).with(anything, 'UNDEF!!', is_a(Hash)).returns("FINAL")
    assert_equal "FINAL", profile_sex_icon(build(Person, :sex => nil))
  end

  should 'not draw sex icon for non-person profiles' do
    assert_equal '', profile_sex_icon(Community.new)
  end

  should 'not draw sex icon when disabled in the environment' do
    env = fast_create(Environment, :name => 'env test')
    env.expects(:enabled?).with('disable_gender_icon').returns(true)
    stubs(:environment).returns(env)
    assert_equal '', profile_sex_icon(build(Person, :sex => 'male'))
  end

  should 'gravatar default parameter' do
    profile = mock
    profile.stubs(:theme).returns('some-theme')
    stubs(:profile).returns(profile)

    NOOSFERO_CONF.stubs(:[]).with('gravatar').returns('crazyvatar')
    assert_equal gravatar_default, 'crazyvatar'

    stubs(:theme_option).returns('gravatar' => 'nicevatar')
    NOOSFERO_CONF.stubs(:[]).with('gravatar').returns('nicevatar')
    assert_equal gravatar_default, 'nicevatar'
  end

  should "secret-profile css applied in the secret profile image" do
    @plugins = mock
    @plugins.stubs(:dispatch_first).returns(false)
    env = Environment.default
    stubs(:environment).returns(env)
    stubs(:profile).returns(profile)
    profile = fast_create(Community, :environment_id => env.id, :secret => true)
    info = {:value =>_('New'), :class => 'new-profile'}
    html = profile_image_link(profile, size=:portrait, tag='li', extra_info = info)
    assert_tag_in_string html, :tag => 'span', :attributes => { :class => 'profile-image secret-profile new-profile' }
  end
end
