require File.dirname(__FILE__) + '/../test_helper'

class ApplicationHelperTest < Test::Unit::TestCase

  include ApplicationHelper

  def setup
    self.stubs(:session).returns({})
  end

  should 'calculate correctly partial for models' do
    p1 = 'path1/'
    p2 = 'path2/'
    @controller = mock()
    @controller.stubs(:view_paths).returns([p1,p2])

    self.stubs(:params).returns({:controller => 'test'})

    File.expects(:exists?).with(p1+"test/_integer.rhtml").returns(true)

    File.expects(:exists?).with(p1+"test/_float.rhtml").returns(false)
    File.expects(:exists?).with(p1+"test/_float.html.erb").returns(false)
    File.expects(:exists?).with(p2+"test/_float.rhtml").returns(false)
    File.expects(:exists?).with(p2+"test/_float.html.erb").returns(false)
    File.expects(:exists?).with(p1+"test/_numeric.rhtml").returns(false)
    File.expects(:exists?).with(p1+"test/_object.rhtml").returns(false)
    File.expects(:exists?).with(p1+"test/_object.html.erb").returns(false)
    File.expects(:exists?).with(p1+"test/_numeric.html.erb").returns(false)
    File.expects(:exists?).with(p2+"test/_numeric.rhtml").returns(true)

    File.expects(:exists?).with(p1+"test/_object.rhtml").returns(false)
    File.expects(:exists?).with(p1+"test/_object.html.erb").returns(false)
    File.expects(:exists?).with(p2+"test/_object.rhtml").returns(false)
    File.expects(:exists?).with(p2+"test/_object.html.erb").returns(false)

    assert_equal 'integer', partial_for_class(Integer)
    assert_equal 'numeric', partial_for_class(Float)
    assert_raises ArgumentError do
      partial_for_class(Object)
    end
  end

  should 'calculate correctly partial for namespaced models' do
    p = 'path/'
    @controller = mock()
    @controller.stubs(:view_paths).returns([p])
    self.stubs(:params).returns({:controller => 'test'})

    class School; class Project; end; end

    File.expects(:exists?).with(p+"test/application_helper_test/school/_project.rhtml").returns(true)

    assert_equal 'test/application_helper_test/school/project', partial_for_class(School::Project)
  end

  should 'look for superclasses on view_for_profile actions' do
    File.expects(:exists?).with("#{RAILS_ROOT}/app/views/blocks/profile_info_actions/float.rhtml").returns(false)
    File.expects(:exists?).with("#{RAILS_ROOT}/app/views/blocks/profile_info_actions/float.html.erb").returns(false)
    File.expects(:exists?).with("#{RAILS_ROOT}/app/views/blocks/profile_info_actions/numeric.rhtml").returns(false)
    File.expects(:exists?).with("#{RAILS_ROOT}/app/views/blocks/profile_info_actions/numeric.html.erb").returns(true)

    assert_equal 'blocks/profile_info_actions/numeric.html.erb', view_for_profile_actions(Float)
  end

  should 'give error when there is no partial for class' do
    assert_raises ArgumentError do
      partial_for_class(nil)
    end
  end

  should 'generate link to stylesheet' do
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', 'stylesheets', 'something.css')).returns(true)
    expects(:filename_for_stylesheet).with('something', nil).returns('/stylesheets/something.css')
    assert_match '@import url(/stylesheets/something.css)', stylesheet_import('something')
  end

  should 'not generate link to unexisting stylesheet' do
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', 'stylesheets', 'something.css')).returns(false)
    expects(:filename_for_stylesheet).with('something', nil).returns('/stylesheets/something.css')
    assert_no_match %r{@import url(/stylesheets/something.css)}, stylesheet_import('something')
  end

  should 'handle nil dates' do
    assert_equal '', show_date(nil)
  end


  should 'append with-text class and keep existing classes' do
    expects(:button_without_text).with('type', 'label', 'url', { :class => 'with-text class1'})
    button('type', 'label', 'url', { :class => 'class1' })
  end

  should 'generate correct link to category' do
    cat = mock
    cat.expects(:path).returns('my-category/my-subcatagory')
    cat.expects(:full_name).returns('category name')
    cat.expects(:environment).returns(Environment.default)
    Environment.any_instance.expects(:default_hostname).returns('example.com')

    result = "/cat/my-category/my-subcatagory"
    expects(:link_to).with('category name', :controller => 'search', :action => 'category_index', :category_path => ['my-category', 'my-subcatagory'], :host => 'example.com').returns(result)
    assert_same result, link_to_category(cat)
  end

  should 'nil theme option when no exists theme' do
    stubs(:current_theme).returns('something-very-unlikely')
    File.expects(:exists?).returns(false)
    assert_nil theme_option()
  end

  should 'nil javascript theme when no exists theme' do
    stubs(:current_theme).returns('something-very-unlikely')
    File.expects(:exists?).returns(false)
    assert_nil theme_javascript
  end

  should 'role color for admin role' do
    assert_equal 'blue', role_color(Profile::Roles.admin(Environment.default.id), Environment.default.id)
  end
  should 'role color for member role' do
    assert_equal 'green', role_color(Profile::Roles.member(Environment.default.id), Environment.default.id)
  end
  should 'role color for moderator role' do
    assert_equal 'gray', role_color(Profile::Roles.moderator(Environment.default.id), Environment.default.id)
  end
  should 'default role color' do
    assert_equal 'black', role_color('none', Environment.default.id)
  end

  should 'rolename for first organization member' do
    person = create_user('usertest').person
    community = fast_create(Community, :name => 'new community', :identifier => 'new-community', :environment_id => Environment.default.id)
    community.add_member(person)
    assert_tag_in_string rolename_for(person, community), :tag => 'span', :content => 'Profile Administrator'
  end

  should 'rolename for a member' do
    member1 = create_user('usertest1').person
    member2 = create_user('usertest2').person
    community = fast_create(Community, :name => 'new community', :identifier => 'new-community', :environment_id => Environment.default.id)
    community.add_member(member1)
    community.add_member(member2)
    assert_tag_in_string rolename_for(member2, community), :tag => 'span', :content => 'Profile Member'
  end

  should 'get theme from environment by default' do
    @environment = mock
    @environment.stubs(:theme).returns('my-environment-theme')
    stubs(:profile).returns(nil)
    assert_equal 'my-environment-theme', current_theme
  end

  should 'get theme from profile when profile is present' do
    profile = mock
    profile.stubs(:theme).returns('my-profile-theme')
    stubs(:profile).returns(profile)
    assert_equal 'my-profile-theme', current_theme
  end

  should 'override theme with testing theme from session' do
    stubs(:session).returns(:theme => 'theme-under-test')
    assert_equal 'theme-under-test', current_theme
  end

  should 'point to system theme path by default' do
    expects(:current_theme).returns('my-system-theme')
    assert_equal '/designs/themes/my-system-theme', theme_path
  end

  should 'point to user theme path when testing theme' do
    stubs(:session).returns({:theme => 'theme-under-test'})
    assert_equal '/user_themes/theme-under-test', theme_path
  end

  should 'render theme footer' do
    stubs(:theme_path).returns('/user_themes/mytheme')
    footer_path = RAILS_ROOT + '/public/user_themes/mytheme/footer.rhtml'

    File.expects(:exists?).with(footer_path).returns(true)
    expects(:render).with(:file => footer_path, :use_full_path => false).returns("BLI")

    assert_equal "BLI", theme_footer
  end

  should 'ignore unexisting theme footer' do
    stubs(:theme_path).returns('/user_themes/mytheme')
    footer_path = RAILS_ROOT + '/public/user_themes/mytheme/footer.rhtml'
    alternate_footer_path = RAILS_ROOT + '/public/user_themes/mytheme/footer.html.erb'

    File.expects(:exists?).with(footer_path).returns(false)
    File.expects(:exists?).with(alternate_footer_path).returns(false)
    expects(:render).with(:file => footer).never

    assert_nil theme_footer
  end

  should 'render theme site title' do
    stubs(:theme_path).returns('/user_themes/mytheme')
    site_title_path = RAILS_ROOT + '/public/user_themes/mytheme/site_title.rhtml'

    File.expects(:exists?).with(site_title_path).returns(true)
    expects(:render).with(:file => site_title_path, :use_full_path => false).returns("Site title")

    assert_equal "Site title", theme_site_title
  end

  should 'ignore unexisting theme site title' do
    stubs(:theme_path).returns('/user_themes/mytheme')
    site_title_path = RAILS_ROOT + '/public/user_themes/mytheme/site_title.rhtml'
    alternate_site_title_path = RAILS_ROOT + '/public/user_themes/mytheme/site_title.html.erb'

    File.expects(:exists?).with(site_title_path).returns(false)
    File.expects(:exists?).with(alternate_site_title_path).returns(false)
    expects(:render).with(:file => site_title_path).never

    assert_nil theme_site_title
  end

  should 'expose theme owner' do
    theme = mock
    profile = mock
    Theme.expects(:find).with('theme-under-test').returns(theme)
    theme.expects(:owner).returns(profile)
    profile.expects(:identifier).returns('sampleuser')

    stubs(:current_theme).returns('theme-under-test')

    assert_equal 'sampleuser', theme_owner
  end

  should 'use environment´s template when there is no profile' do
    stubs(:profile).returns(nil)
    environment.expects(:layout_template).returns('sometemplate')
    assert_equal "/designs/templates/sometemplate/stylesheets/style.css", template_stylesheet_path
  end

  should 'use template from profile' do
    profile = mock
    profile.expects(:layout_template).returns('mytemplate')
    stubs(:profile).returns(profile)

    assert_equal '/designs/templates/mytemplate/stylesheets/style.css', template_stylesheet_path
  end

  should 'use https:// for login_url' do
    environment = Environment.default
    environment.update_attribute(:enable_ssl, true)
    environment.domains << Domain.new(:name => "test.domain.net", :is_default => true)
    stubs(:environment).returns(environment)

    stubs(:url_for).with(has_entries(:protocol => 'https://', :host => 'test.domain.net')).returns('LALALA')

    assert_equal 'LALALA', login_url
  end

  should 'not force ssl in login_url when environment has ssl disabled' do
    environment = mock
    environment.expects(:enable_ssl).returns(false).at_least_once
    stubs(:environment).returns(environment)
    request = mock
    request.stubs(:host).returns('localhost')
    stubs(:request).returns(request)

    expects(:url_for).with(has_entries(:protocol => 'https://')).never
    expects(:url_for).with(has_key(:controller)).returns("LALALA")
    assert_equal "LALALA", login_url
  end

  should 'return nil if disable_categories is enabled' do
    env = fast_create(Environment, :name => 'env test')
    stubs(:environment).returns(env)
    assert_not_nil env
    env.enable(:disable_categories)
    assert env.enabled?(:disable_categories)
    assert_nil select_categories(mock)
  end

  should 'provide sex icon for males' do
    stubs(:environment).returns(Environment.default)
    expects(:content_tag).with(anything, 'male').returns('MALE!!')
    expects(:content_tag).with(anything, 'MALE!!', is_a(Hash)).returns("FINAL")
    assert_equal "FINAL", profile_sex_icon(Person.new(:sex => 'male'))
  end

  should 'provide sex icon for females' do
    stubs(:environment).returns(Environment.default)
    expects(:content_tag).with(anything, 'female').returns('FEMALE!!')
    expects(:content_tag).with(anything, 'FEMALE!!', is_a(Hash)).returns("FINAL")
    assert_equal "FINAL", profile_sex_icon(Person.new(:sex => 'female'))
  end

  should 'provide undef sex icon' do
    stubs(:environment).returns(Environment.default)
    expects(:content_tag).with(anything, 'undef').returns('UNDEF!!')
    expects(:content_tag).with(anything, 'UNDEF!!', is_a(Hash)).returns("FINAL")
    assert_equal "FINAL", profile_sex_icon(Person.new(:sex => nil))
  end

  should 'not draw sex icon for non-person profiles' do
    assert_equal '', profile_sex_icon(Community.new)
  end

  should 'not draw sex icon when disabled in the environment' do
    env = fast_create(Environment, :name => 'env test')
    env.expects(:enabled?).with('disable_gender_icon').returns(true)
    stubs(:environment).returns(env)
    assert_equal '', profile_sex_icon(Person.new(:sex => 'male'))
  end

  should 'display field on person signup' do
    env = Environment.create!(:name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.expects(:action_name).returns('signup')

    person = Person.new
    person.expects(:signup_fields).returns(['field'])
    assert_equal 'SIGNUP_FIELD', optional_field(person, 'field', 'SIGNUP_FIELD')
  end

  should 'display field on enterprise registration' do
    env = Environment.create!(:name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.stubs(:controller_name).returns('enterprise_registration')
    controller.stubs(:action_name).returns('index')

    enterprise = Enterprise.new
    enterprise.expects(:signup_fields).returns(['field'])
    assert_equal 'SIGNUP_FIELD', optional_field(enterprise, 'field', 'SIGNUP_FIELD')
  end

  should 'display field on community creation' do
    env = Environment.create!(:name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.stubs(:action_name).returns('new_community')

    community = Community.new
    community.expects(:signup_fields).returns(['field'])
    assert_equal 'SIGNUP_FIELD', optional_field(community, 'field', 'SIGNUP_FIELD')
  end

  should 'not display field on signup' do
    env = fast_create(Environment, :name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.expects(:action_name).returns('signup')

    person = Person.new
    person.expects(:signup_fields).returns([])
    assert_equal '', optional_field(person, 'field', 'SIGNUP_FIELD')
  end

  should 'not display field on enterprise registration' do
    env = Environment.create!(:name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.stubs(:controller_name).returns('enterprise_registration')
    controller.stubs(:action_name).returns('index')

    enterprise = Enterprise.new
    enterprise.expects(:signup_fields).returns([])
    assert_equal '', optional_field(enterprise, 'field', 'SIGNUP_FIELD')
  end

  should 'not display field on community creation' do
    env = Environment.create!(:name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.stubs(:action_name).returns('new_community')

    community = Community.new
    community.stubs(:signup_fields).returns([])
    assert_equal '', optional_field(community, 'field', 'SIGNUP_FIELD')
  end

  should 'display active fields' do
    env = fast_create(Environment, :name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.stubs(:controller_name).returns('')
    controller.stubs(:action_name).returns('edit')

    profile = Person.new
    profile.expects(:active_fields).returns(['field'])
    assert_equal 'SIGNUP_FIELD', optional_field(profile, 'field', 'SIGNUP_FIELD')
  end

  should 'not display active fields' do
    env = fast_create(Environment, :name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.stubs(:action_name).returns('edit')
    controller.stubs(:controller_name).returns('')

    profile = Person.new
    profile.expects(:active_fields).returns([])
    assert_equal '', optional_field(profile, 'field', 'SIGNUP_FIELD')
  end

  should 'display required fields' do
    env = fast_create(Environment, :name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.stubs(:controller_name).returns('')
    controller.stubs(:action_name).returns('edit')

    stubs(:required).with('SIGNUP_FIELD').returns('<span>SIGNUP_FIELD</span>')
    profile = Person.new
    profile.expects(:active_fields).returns(['field'])
    profile.expects(:required_fields).returns(['field'])
    assert_equal '<span>SIGNUP_FIELD</span>', optional_field(profile, 'field', 'SIGNUP_FIELD')
  end

  should 'base theme uses default icon theme' do
    stubs(:current_theme).returns('base')
    assert_equal "/designs/icons/default/style.css", icon_theme_stylesheet_path.first
  end

  should 'base theme uses config to specify more then an icon theme' do
    stubs(:current_theme).returns('base')
    assert_includes icon_theme_stylesheet_path, "/designs/icons/default/style.css"
    assert_includes icon_theme_stylesheet_path, "/designs/icons/pidgin/style.css"
  end

  should 'not display active field if only required' do
    profile = mock
    profile.expects(:required_fields).returns([])

    assert_equal '', optional_field(profile, :field_name, '<html tags>', true)
  end

  should 'display name on page title if profile doesnt have nickname' do
    stubs(:environment).returns(Environment.default)
    @controller = ApplicationController.new

    c = fast_create(Community, :name => 'Comm name', :identifier => 'test_comm')
    stubs(:profile).returns(c)
    assert_match(/Comm name/, page_title)
  end

  should 'display nickname on page title if profile has nickname' do
    stubs(:environment).returns(Environment.default)
    @controller = ApplicationController.new

    c = fast_create(Community, :name => 'Community for tests', :nickname => 'Community nick', :identifier => 'test_comm')
    stubs(:profile).returns(c)
    assert_match(/Community nick/, page_title)
  end

  should 'generate a gravatar url' do
    stubs(:theme_option).returns({})
    with_constants :NOOSFERO_CONF => {'gravatar' => 'crazyvatar'} do
      url = str_gravatar_url_for( 'rms@gnu.org', :size => 50 )
      assert_match(/^http:\/\/www\.gravatar\.com\/avatar\.php\?/, url)
      assert_match(/(\?|&)gravatar_id=ed5214d4b49154ba0dc397a28ee90eb7(&|$)/, url)
      assert_match(/(\?|&)d=crazyvatar(&|$)/, url)
      assert_match(/(\?|&)size=50(&|$)/, url)
    end
    stubs(:theme_option).returns('gravatar' => 'nicevatar')
    with_constants :NOOSFERO_CONF => {'gravatar' => 'crazyvatar'} do
      url = str_gravatar_url_for( 'rms@gnu.org', :size => 50 )
      assert_match(/^http:\/\/www\.gravatar\.com\/avatar\.php\?/, url)
      assert_match(/(\?|&)gravatar_id=ed5214d4b49154ba0dc397a28ee90eb7(&|$)/, url)
      assert_match(/(\?|&)d=nicevatar(&|$)/, url)
      assert_match(/(\?|&)size=50(&|$)/, url)
    end
  end

  should 'use theme passed via param when in development mode' do
    stubs(:environment).returns(Environment.new(:theme => 'environment-theme'))
    ENV.stubs(:[]).with('RAILS_ENV').returns('development')
    self.stubs(:params).returns({:theme => 'skyblue'})
    assert_equal 'skyblue', current_theme
  end

  should 'not use theme passed via param when in production mode' do
    stubs(:environment).returns(Environment.new(:theme => 'environment-theme'))
    ENV.stubs(:[]).with('RAILS_ENV').returns('production')
    self.stubs(:params).returns({:theme => 'skyblue'})
    stubs(:profile).returns(Profile.new(:theme => 'profile-theme'))
    assert_equal 'profile-theme', current_theme
  end

  should 'use environment theme if the profile theme is nil' do
    stubs(:environment).returns(fast_create(Environment, :theme => 'new-theme'))
    stubs(:profile).returns(fast_create(Profile))
    assert_equal environment.theme, current_theme
  end

  should 'trunc to 15 chars the big filename' do
    assert_equal 'AGENDA(...).mp3', short_filename('AGENDA_CULTURA_-_FESTA_DE_VAQUEIROS_PONTO_DE_SERRA_PRETA_BAIXA.mp3',15)
  end

  should 'trunc to default limit the big filename' do
    assert_equal 'AGENDA_CULTURA_-_FESTA_DE_VAQUEIRO(...).mp3', short_filename('AGENDA_CULTURA_-_FESTA_DE_VAQUEIROS_PONTO_DE_SERRA_PRETA_BAIXA.mp3')
  end

  should 'does not trunc short filename' do
    assert_equal 'filename.mp3', short_filename('filename.mp3')
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
    person = Person.new
    person.stubs(:url).returns('url for person')
    person.stubs(:public_profile_url).returns('url for person')
    links = links_for_balloon(person)
    assert_equal ['Wall', 'Friends', 'Communities', 'Send an e-mail', 'Add'], links.map{|i| i.keys.first}
  end

  should 'return ordered list of links to balloon to Community' do
    env = Environment.default
    env.stubs(:enabled?).with(:show_balloon_with_profile_links_when_clicked).returns(true)
    stubs(:environment).returns(env)
    community = Community.new
    community.stubs(:url).returns('url for community')
    community.stubs(:public_profile_url).returns('url for community')
    links = links_for_balloon(community)
    assert_equal ['Wall', 'Members', 'Agenda', 'Join', 'Leave', 'Send an e-mail'], links.map{|i| i.keys.first}
  end

  should 'return ordered list of links to balloon to Enterprise' do
    env = Environment.default
    env.stubs(:enabled?).with(:show_balloon_with_profile_links_when_clicked).returns(true)
    stubs(:environment).returns(env)
    enterprise = Enterprise.new
    enterprise.stubs(:url).returns('url for enterprise')
    enterprise.stubs(:public_profile_url).returns('url for enterprise')
    stubs(:catalog_path)
    links = links_for_balloon(enterprise)
    assert_equal ['Products', 'Members', 'Agenda', 'Send an e-mail'], links.map{|i| i.keys.first}
  end

  should 'use favicon from environment theme if does not have profile' do
    stubs(:environment).returns(fast_create(Environment, :theme => 'new-theme'))
    stubs(:profile).returns(nil)
    assert_equal '/designs/themes/new-theme/favicon.ico', theme_favicon
  end

  should 'use favicon from environment theme if the profile theme is nil' do
    stubs(:environment).returns(fast_create(Environment, :theme => 'new-theme'))
    stubs(:profile).returns(fast_create(Profile))
    assert_equal '/designs/themes/new-theme/favicon.ico', theme_favicon
  end

  should 'use favicon from profile theme if the profile has theme' do
    stubs(:environment).returns(fast_create(Environment, :theme => 'new-theme'))
    stubs(:profile).returns(fast_create(Profile, :theme => 'profile-theme'))
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', '/designs/themes/profile-theme', 'favicon.ico')).returns(true)
    assert_equal '/designs/themes/profile-theme/favicon.ico', theme_favicon
  end

  should 'use favicon from profile articles if the profile theme does not have' do
    stubs(:environment).returns(fast_create(Environment, :theme => 'new-theme'))
    stubs(:profile).returns(fast_create(Profile, :theme => 'profile-theme'))
    file = UploadedFile.create!(:uploaded_data => fixture_file_upload('/files/favicon.ico', 'image/x-ico'), :profile => profile)
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', theme_path, 'favicon.ico')).returns(false)

    assert_match /favicon.ico/, theme_favicon
  end

  should 'use favicon from environment if the profile theme and profile articles do not have' do
    stubs(:environment).returns(fast_create(Environment, :theme => 'new-theme'))
    stubs(:profile).returns(fast_create(Profile, :theme => 'profile-theme'))
    File.expects(:exists?).with(File.join(RAILS_ROOT, 'public', theme_path, 'favicon.ico')).returns(false)
    assert_equal '/designs/themes/new-theme/favicon.ico', theme_favicon
  end

  should 'include item in usermenu for environment enabled features' do
    env = Environment.new
    env.enable('xmpp_chat')
    stubs(:environment).returns(env)

    @controller = ApplicationController.new
    path = File.join(RAILS_ROOT, 'app', 'views')
    @controller.stubs(:view_paths).returns(path)

    file = path + '/shared/usermenu/xmpp_chat.rhtml'
    expects(:render).with(:file => file, :use_full_path => false).returns('Open chat')

    assert_equal 'Open chat', render_environment_features(:usermenu)
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

  should 'pluralize without count' do
    assert_equal "tests", pluralize_without_count(2, "test")
    assert_equal "test", pluralize_without_count(1, "test")
    assert_equal "testes", pluralize_without_count(2, "test", "testes")
  end

  should 'unique with count' do
    assert_equal ["1 for b", "2 for c", "3 for a"], unique_with_count(%w(a b c a c a))
  end

  should 'show task information with the requestor' do
    person = create_user('usertest').person
    task = Task.create(:requestor => person)
    assert_match person.name, task_information(task)
  end

  should 'return nil when :show_zoom_button_on_article_images is not enabled in environment' do
    env = Environment.default
    env.stubs(:enabled?).with(:show_zoom_button_on_article_images).returns(false)
    stubs(:environment).returns(env)
    assert_nil add_zoom_to_images
  end

  should 'return code when :show_zoom_button_on_article_images is enabled in environment' do
    env = Environment.default
    env.stubs(:enabled?).with(:show_zoom_button_on_article_images).returns(true)
    stubs(:environment).returns(env)
    assert_not_nil add_zoom_to_images
  end

  protected
  include NoosferoTestHelper

end
