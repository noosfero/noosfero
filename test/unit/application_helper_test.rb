# encoding: UTF-8
require_relative "../test_helper"

class ApplicationHelperTest < ActionView::TestCase

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
    File.stubs(:exists?).returns(false)

    File.expects(:exists?).with(p1+"test/_integer.html.erb").returns(true)
    assert_equal 'integer', partial_for_class(Integer)

    File.expects(:exists?).with(p1+"test/_numeric.html.erb").returns(true)
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

    File.stubs(:exists?).returns(false)
    File.expects(:exists?).with(p+"test/application_helper_test/school/_project.html.erb").returns(true)

    assert_equal 'test/application_helper_test/school/project', partial_for_class(School::Project)
  end

  should 'give error when there is no partial for class' do
    assert_raises ArgumentError do
      partial_for_class(nil)
    end
  end

  should 'plugins path take precedence over core path' do
    core_path = 'core/'
    plugin_path = 'path/'
    @controller = mock()
    @controller.stubs(:view_paths).returns([plugin_path, core_path])
    self.stubs(:params).returns({:controller => 'test'})

    File.stubs(:exists?).returns(false)
    File.stubs(:exists?).with(core_path+"test/_block.html.erb").returns(true)
    File.stubs(:exists?).with(plugin_path+"test/_raw_html_block.html.erb").returns(true)

    assert_equal 'raw_html_block', partial_for_class(RawHTMLBlock)
  end

  should 'generate link to stylesheet' do
    File.stubs(:exists?).returns(false)
    File.expects(:exists?).with(Rails.root.join('public', 'stylesheets', 'something.css')).returns(true)
    expects(:filename_for_stylesheet).with('something', nil).returns('/stylesheets/something.css')
    assert_match '@import url(/stylesheets/something.css)', stylesheet_import('something')
  end

  should 'not generate link to unexisting stylesheet' do
    File.expects(:exists?).with(Rails.root.join('public', 'stylesheets', 'something.css')).returns(false)
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
    expects(:link_to).with('category name', {:controller => 'search', :action => 'category_index', :category_path => ['my-category', 'my-subcatagory'], :host => 'example.com'}, {}).returns(result)
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

  should 'rolenames for a member admin' do
    member1 = create_user('usertest1').person
    member2 = create_user('usertest2').person
    community = fast_create(Community, :name => 'new community', :identifier => 'new-community', :environment_id => Environment.default.id)
    community.add_member(member1)
    # member2 is both a admin and a member
    community.add_member(member2)
    community.add_admin(member2)
    assert_tag_in_string rolename_for(member2, community), :tag => 'span', :content => 'Profile Member'
    assert_tag_in_string rolename_for(member2, community), :tag => 'span', :content => 'Profile Administrator'
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
    footer_path = Rails.root.join('public', 'user_themes', 'mytheme', 'footer.html.erb')

    File.expects(:exists?).with(footer_path).returns(true)
    expects(:render).with(:file => footer_path, :use_full_path => false).returns("BLI")

    assert_equal "BLI", theme_footer
  end

  should 'ignore unexisting theme footer' do
    stubs(:theme_path).returns('/user_themes/mytheme')
    footer_path = Rails.root.join('public', 'user_themes', 'mytheme', 'footer.html.erb')

    File.expects(:exists?).with(footer_path).returns(false)
    expects(:render).with(:file => footer).never

    assert_nil theme_footer
  end

  should 'render theme site title' do
    stubs(:theme_path).returns('/user_themes/mytheme')
    site_title_path = Rails.root.join('public', 'user_themes', 'mytheme', 'site_title.html.erb')

    File.expects(:exists?).with(site_title_path).returns(true)
    expects(:render).with(:file => site_title_path, :use_full_path => false).returns("Site title")

    assert_equal "Site title", theme_site_title
  end

  should 'ignore unexisting theme site title' do
    stubs(:theme_path).returns('/user_themes/mytheme')
    site_title_path = Rails.root.join('public', 'user_themes', 'mytheme', 'site_title.html.erb')

    File.expects(:exists?).with(site_title_path).returns(false)
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
    self.stubs(:environment).returns(Environment.default)
    environment.expects(:layout_template).returns('sometemplate')
    assert_equal "/designs/templates/sometemplate/stylesheets/style.css", template_stylesheet_path
  end

  should 'use template from profile' do
    profile = mock
    profile.expects(:layout_template).returns('mytemplate')
    stubs(:profile).returns(profile)

    assert_equal '/designs/templates/mytemplate/stylesheets/style.css', template_stylesheet_path
  end

  should 'not display templates options when there is no template' do
    self.stubs(:environment).returns(Environment.default)
    [:people, :communities, :enterprises].each do |klass|
      assert_equal '', template_options(klass, 'profile_data')
    end
  end

  should 'define the community default template as checked' do
    environment = Environment.default
    self.stubs(:environment).returns(environment)
    community = fast_create(Community, :is_template => true, :environment_id => environment.id)
    fast_create(Community, :is_template => true, :environment_id => environment.id)
    environment.community_default_template= community
    environment.save

    assert_tag_in_string template_options(:communities, 'community'), :tag => 'input',
                                 :attributes => { :name => "community[template_id]", :value => community.id, :checked => true }
  end

  should 'define the person default template as checked' do
    environment = Environment.default
    self.stubs(:environment).returns(environment)
    person = fast_create(Person, :is_template => true, :environment_id => environment.id)
    fast_create(Person, :is_template => true, :environment_id => environment.id)
    environment.person_default_template= person
    environment.save

    assert_tag_in_string template_options(:people, 'profile_data'), :tag => 'input',
                                 :attributes => { :name => "profile_data[template_id]", :value => person.id, :checked => true }
  end

  should 'define the enterprise default template as checked' do
    environment = Environment.default
    self.stubs(:environment).returns(environment)
    enterprise = fast_create(Enterprise, :is_template => true, :environment_id => environment.id)
    fast_create(Enterprise, :is_template => true, :environment_id => environment.id)

    environment.enterprise_default_template= enterprise
    environment.save
    environment.reload

    assert_tag_in_string template_options(:enterprises, 'create_enterprise'), :tag => 'input',
                                 :attributes => { :name => "create_enterprise[template_id]", :value => enterprise.id, :checked => true }
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

  should 'display field on person signup' do
    env = create(Environment, :name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.expects(:action_name).returns('signup')

    person = Person.new
    person.expects(:signup_fields).returns(['field'])
    assert_equal 'SIGNUP_FIELD', optional_field(person, 'field', 'SIGNUP_FIELD')
  end

  should 'display field on enterprise registration' do
    env = create(Environment, :name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.stubs(:controller_name).returns('enterprise_registration')
    controller.stubs(:action_name).returns('index')

    enterprise = Enterprise.new
    enterprise.expects(:signup_fields).returns(['field'])
    assert_equal 'SIGNUP_FIELD', optional_field(enterprise, 'field', 'SIGNUP_FIELD')
  end

  should 'display field on home for a not logged user' do
    env = create(Environment, :name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.stubs(:controller_name).returns('home')
    controller.stubs(:action_name).returns('index')

    stubs(:user).returns(nil)


    person = Person.new
    person.expects(:signup_fields).returns(['field'])
    assert_equal 'SIGNUP_FIELD', optional_field(person, 'field', 'SIGNUP_FIELD')
  end

  should 'display field on community creation' do
    env = create(Environment, :name => 'env test')
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
    env = create(Environment, :name => 'env test')
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
    env = create(Environment, :name => 'env test')
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
    profile.stubs(:active_fields).returns(['field'])

    expects(:profile_field_privacy_selector).with(profile, 'field').returns('')
    assert_tag_in_string optional_field(profile, 'field', 'EDIT_FIELD'), :tag => 'div', :content => 'EDIT_FIELD', :attributes => {:class => 'field-with-privacy-selector'}
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
    assert_equal '', optional_field(profile, 'field', 'EDIT_FIELD')
  end

  should 'display required fields' do
    env = fast_create(Environment, :name => 'env test')
    stubs(:environment).returns(env)

    controller = mock
    stubs(:controller).returns(controller)
    controller.stubs(:controller_name).returns('')
    controller.stubs(:action_name).returns('edit')

    profile = Person.new
    profile.stubs(:active_fields).returns(['field'])
    profile.expects(:required_fields).returns(['field'])

    stubs(:required).with(anything).returns('<span>EDIT_FIELD</span>')
    expects(:profile_field_privacy_selector).with(profile, 'field').returns('')
    assert_equal '<span>EDIT_FIELD</span>', optional_field(profile, 'field', 'EDIT_FIELD')
  end

  should 'base theme uses default icon theme' do
    stubs(:current_theme).returns('base')
    assert_equal "designs/icons/default/style.css", icon_theme_stylesheet_path.first
  end

  should 'base theme uses config to specify more then an icon theme' do
    stubs(:current_theme).returns('base')
    assert_includes icon_theme_stylesheet_path, "designs/icons/default/style.css"
    assert_includes icon_theme_stylesheet_path, "designs/icons/pidgin/style.css"
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

  should 'not display environment name if is a profile' do
    stubs(:environment).returns(Environment.default)
    @controller = ApplicationController.new

    c = fast_create(Community, :name => 'Community for tests', :nickname => 'Community nick', :identifier => 'test_comm')
    stubs(:profile).returns(c)
    assert_equal c.short_name, page_title
  end

  should 'display only environment if no profile and page' do
    stubs(:environment).returns(Environment.default)
    @controller = ApplicationController.new

    assert_equal Environment.default.name, page_title
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

  should 'use theme passed via param when in development mode' do
    stubs(:environment).returns(build(Environment, :theme => 'environment-theme'))
    Rails.env.stubs(:development?).returns(true)
    self.stubs(:params).returns({:theme => 'skyblue'})
    assert_equal 'skyblue', current_theme
  end

  should 'not use theme passed via param when in production mode' do
    stubs(:environment).returns(build(Environment, :theme => 'environment-theme'))
    ENV.stubs(:[]).with('RAILS_ENV').returns('production')
    self.stubs(:params).returns({:theme => 'skyblue'})
    stubs(:profile).returns(build(Profile, :theme => 'profile-theme'))
    assert_equal 'profile-theme', current_theme
  end

  should 'use environment theme if the profile theme is nil' do
    stubs(:environment).returns(fast_create(Environment, :theme => 'new-theme'))
    stubs(:profile).returns(fast_create(Profile))
    assert_equal environment.theme, current_theme
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
    File.expects(:exists?).with(Rails.root.join('public', '/designs/themes/profile-theme', 'favicon.ico')).returns(true)
    assert_equal '/designs/themes/profile-theme/favicon.ico', theme_favicon
  end

  should 'use favicon from profile articles if the profile theme does not have' do
    stubs(:environment).returns(fast_create(Environment, :theme => 'new-theme'))
    stubs(:profile).returns(fast_create(Profile, :theme => 'profile-theme'))
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/favicon.ico', 'image/x-ico'), :profile => profile)
    File.expects(:exists?).with(Rails.root.join('public', theme_path, 'favicon.ico')).returns(false)

    assert_match /favicon.ico/, theme_favicon
  end

  should 'use favicon from environment if the profile theme and profile articles do not have' do
    stubs(:environment).returns(fast_create(Environment, :theme => 'new-theme'))
    stubs(:profile).returns(fast_create(Profile, :theme => 'profile-theme'))
    File.expects(:exists?).with(Rails.root.join('public', theme_path, 'favicon.ico')).returns(false)
    assert_equal '/designs/themes/new-theme/favicon.ico', theme_favicon
  end

  should 'not inlude administration link if user is not an environment administrator' do
    user = mock()
    stubs(:environment).returns(Environment.default)
    user.stubs(:is_admin?).with(environment).returns(false)
    stubs(:user).returns(user)
    assert admin_link.blank?
  end

  should 'inlude administration link if user is an environment administrator' do
    user = mock()
    stubs(:environment).returns(Environment.default)
    user.stubs(:is_admin?).with(environment).returns(true)
    stubs(:user).returns(user)
    assert admin_link.present?
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
    task = create(Task, :requestor => person)
    assert_match person.name, task_information(task)
  end

  should 'return nil when :show_zoom_button_on_article_images is not enabled in environment' do
    env = Environment.default
    env.stubs(:enabled?).with(:show_zoom_button_on_article_images).returns(false)
    stubs(:environment).returns(env)
    assert_nil add_zoom_to_article_images
  end

  should 'return code when :show_zoom_button_on_article_images is enabled in environment' do
    env = Environment.default
    env.stubs(:enabled?).with(:show_zoom_button_on_article_images).returns(true)
    stubs(:environment).returns(env)
    assert_not_nil add_zoom_to_article_images
  end

  should 'return code when add_zoom_to_images' do
    env = Environment.default
    assert_not_nil add_zoom_to_images
  end

  should 'parse macros' do
    class Plugin1 < Noosfero::Plugin
    end
    Noosfero::Plugin.stubs(:all).returns(['ApplicationHelperTest::Plugin1'])

    class Plugin1::Macro1 < Noosfero::Plugin::Macro
      def parse(params, inner_html, source)
        'Test1'
      end
    end

    class Plugin1::Macro2 < Noosfero::Plugin::Macro
      def parse(params, inner_html, source)
        'Test2'
      end
    end

    environment = Environment.default
    environment.enable_plugin(Plugin1)
    @plugins = Noosfero::Plugin::Manager.new(environment, self)
    macro1_name = Plugin1::Macro1.identifier
    macro2_name = Plugin1::Macro2.identifier

    html = "
      <div class='macro nonEdit' data-macro='#{macro1_name}' data-macro-param='123'></div>
      <div class='macro nonEdit' data-macro='#{macro2_name}'></div>
      <div class='macro nonEdit' data-macro='unexistent' data-macro-param='987'></div>
    "
    parsed_html = convert_macro(html, mock())
    parsed_divs = Nokogiri::HTML.fragment(parsed_html).css('div')
    expected_divs = Nokogiri::HTML.fragment("
      <div class='parsed-macro #{macro1_name}' data-macro='#{macro1_name}'>Test1</div>
      <div class='parsed-macro #{macro2_name}' data-macro='#{macro2_name}'>Test2</div>
      <div data-macro='unexistent' class='failed-macro unexistent'>Unsupported macro unexistent!</div>
    ").css('div')

    # comparing div attributes between parsed and expected html
    parsed_divs.each_with_index do |div, i|
      assert_equal expected_divs[i].attributes.to_xml, div.attributes.to_xml
      assert_equal expected_divs[i].inner_text, div.inner_text
    end
  end

  should 'reference to article' do
    c = fast_create(Community)
    a = fast_create(TinyMceArticle, :profile_id => c.id)
    assert_equal(
      "<a href=\"/#{c.identifier}/#{a.slug}\">x</a>",
      reference_to_article('x', a) )
  end

  should 'reference to article, with anchor' do
    c = fast_create(Community)
    a = fast_create(TinyMceArticle, :profile_id => c.id)
    assert_equal(
      "<a href=\"/#{c.identifier}/#{a.slug}#place\">x</a>",
      reference_to_article('x', a, 'place') )
  end

  should 'reference to article, in a blog' do
    c = fast_create(Community)
    b = fast_create(Blog, :profile_id => c.id)
    a = fast_create(TinyMceArticle, :profile_id => c.id, :parent_id => b.id)
    a.save! # needed to link to the parent blog
    assert_equal(
      "<a href=\"/#{c.identifier}/#{b.slug}/#{a.slug}\">x</a>",
      reference_to_article('x', a) )
  end

  should 'reference to article, in a profile with domain' do
    c = fast_create(Community)
    c.domains << build(Domain, :name=>'domain.xyz')
    b = fast_create(Blog, :profile_id => c.id)
    a = fast_create(TinyMceArticle, :profile_id => c.id, :parent_id => b.id)
    a.save!
    assert_equal(
      "<a href=\"http://domain.xyz/#{b.slug}/#{a.slug}\">x</a>",
      reference_to_article('x', a) )
  end

  should 'content_id_to_str return the content id as string' do
    article = fast_create(Article, :name => 'my article')
    response = content_id_to_str(article)
    assert_equal String, response.class
    assert !response.empty?
  end

  should 'content_id_to_str return empty string when receiving nil' do
    assert_equal '', content_id_to_str(nil)
  end

  should 'select gallery as default folder for image upload' do
    profile = create_user('testuser').person
    folder  = fast_create(Folder,  :profile_id => profile.id)
    gallery = fast_create(Gallery, :profile_id => profile.id)
    blog    = fast_create(Blog,    :profile_id => profile.id)
    assert_equal gallery, default_folder_for_image_upload(profile)
  end

  should 'select generic folder as default folder for image upload when no gallery' do
    profile = create_user('testuser').person
    folder  = fast_create(Folder,  :profile_id => profile.id)
    blog    = fast_create(Blog,    :profile_id => profile.id)
    assert_equal folder, default_folder_for_image_upload(profile)
  end

  should 'return nil as default folder for image upload when no gallery or generic folder' do
    profile = create_user('testuser').person
    blog    = fast_create(Blog,    :profile_id => profile.id)
    assert_nil default_folder_for_image_upload(profile)
  end

  should 'envelop a html with button-bar div' do
    result = button_bar { '<b>foo</b>' }
    assert_equal '<div class="button-bar"><b>foo</b>'+
                 '<br style=\'clear: left;\' /></div>', result
  end

  should 'add more classes to button-bar envelope' do
    result = button_bar :class=>'test' do
      '<b>foo</b>'
    end
    assert_equal '<div class="test button-bar"><b>foo</b>'+
                 '<br style=\'clear: left;\' /></div>', result
  end

  should 'add more attributes to button-bar envelope' do
    result = button_bar :id=>'bt1' do
      '<b>foo</b>'
    end
    assert_tag_in_string result, :tag =>'div', :attributes => {:class => 'button-bar', :id => 'bt1'}
    assert_tag_in_string result, :tag =>'b', :content => 'foo', :parent => {:tag => 'div', :attributes => {:id => 'bt1'}}
    assert_tag_in_string result, :tag =>'br', :parent => {:tag => 'div', :attributes => {:id => 'bt1'}}
  end

  should 'not filter html if source does not have macros' do
    class Plugin1 < Noosfero::Plugin
    end

    class Plugin1::Macro1 < Noosfero::Plugin::Macro
      def parse(params, inner_html, source)
        'Test1'
      end
    end

    environment = Environment.default
    environment.enable_plugin(Plugin1)
    @plugins = Noosfero::Plugin::Manager.new(environment, self)
    macro1_name = Plugin1::Macro1.identifier
    source = mock
    source.stubs(:has_macro?).returns(false)

    html = "<div class='macro nonEdit' data-macro='#{macro1_name}' data-macro-param='123'></div>"
    parsed_html = filter_html(html, source)

    assert_no_match /Test1/, parsed_html
  end

  should 'not convert macro if source is nil' do
    profile = create_user('testuser').person
    article = fast_create(Article,  :profile_id => profile.id)
    class Plugin1 < Noosfero::Plugin; end

    environment = Environment.default
    environment.enable_plugin(Plugin1)
    @plugins = Noosfero::Plugin::Manager.new(environment, self)

    expects(:convert_macro).never
    filter_html(article.body, nil)
  end

  should 'not convert macro if there is no macro plugin active' do
    profile = create_user('testuser').person
    article = fast_create(Article,  :profile_id => profile.id)
    class Plugin1 < Noosfero::Plugin; end

    environment = Environment.default
    environment.enable_plugin(Plugin1)
    @plugins = Noosfero::Plugin::Manager.new(environment, self)

    expects(:convert_macro).never
    filter_html(article.body, article)
  end

  should 'not display enterprises if not logged' do
    @controller = ApplicationController.new
    profile = create_user('testuser').person
    profile.environment.enable('display_my_enterprises_on_user_menu')
    enterprise = fast_create(Enterprise)
    enterprise.add_admin(profile)

    stubs(:user).returns(nil)
    expects(:manage_link).with(profile.enterprises, :enterprises, _('My enterprises')).never
    assert_equal '', manage_enterprises
  end

  should 'display enterprises if logged and enabled on environment' do
    @controller = ApplicationController.new
    profile = create_user('testuser').person
    profile.environment.enable('display_my_enterprises_on_user_menu')
    enterprise = fast_create(Enterprise)
    enterprise.add_admin(profile)

    stubs(:user).returns(profile)
    expects(:manage_link).with(profile.enterprises, :enterprises, _('My enterprises')).returns('enterprises list')
    assert_equal 'enterprises list', manage_enterprises
  end

  should 'not display enterprises if logged and disabled on environment' do
    @controller = ApplicationController.new
    profile = create_user('testuser').person
    profile.environment.disable('display_my_enterprises_on_user_menu')
    enterprise = fast_create(Enterprise)
    enterprise.add_admin(profile)

    stubs(:user).returns(profile)
    expects(:manage_link).with(profile.enterprises, :enterprises, _('My enterprises')).never
    assert_equal '', manage_enterprises
  end

  should 'not display communities if not logged' do
    @controller = ApplicationController.new
    profile = create_user('testuser').person
    profile.environment.enable('display_my_communities_on_user_menu')
    community = fast_create(Community)
    community.add_admin(profile)

    stubs(:user).returns(nil)
    expects(:manage_link).with(profile.communities, :communities, _('My communities')).never
    assert_equal '', manage_communities
  end

  should 'display communities if logged and enabled on environment' do
    @controller = ApplicationController.new
    profile = create_user('testuser').person
    profile.environment.enable('display_my_communities_on_user_menu')
    community = fast_create(Community)
    community.add_admin(profile)

    stubs(:user).returns(profile)
    expects(:manage_link).with(profile.communities, :communities, _('My communities')).returns('communities list')
    assert_equal 'communities list', manage_communities
  end

  should 'not display communities if logged and disabled on environment' do
    @controller = ApplicationController.new
    profile = create_user('testuser').person
    profile.environment.disable('display_my_communities_on_user_menu')
    community = fast_create(Community)
    community.add_admin(profile)

    stubs(:user).returns(profile)
    expects(:manage_link).with(profile.communities, :communities, _('My communities')).never
    assert_equal '', manage_communities
  end

  should 'include file from current theme out of a profile page' do
    def profile; nil; end
    def environment; e={}; def e.theme; 'env-theme'; end; e; end
    def render(opt); opt; end
    File.stubs(:exists?).returns(false)
    file = Rails.root.join 'public/designs/themes/env-theme/somefile.html.erb'
    assert_nil theme_include('somefile') # exists? = false
    File.expects(:exists?).with(file).returns(true).at_least_once
    assert_equal file, theme_include('somefile')[:file] # exists? = true
  end

  should 'include file from current theme inside a profile page' do
    def profile; p={}; def p.theme; 'my-theme'; end; p; end
    def render(opt); opt; end
    File.stubs(:exists?).returns(false)
    file = Rails.root.join 'public/designs/themes/my-theme/otherfile.html.erb'
    assert_nil theme_include('otherfile') # exists? = false
    File.expects(:exists?).with(file).returns(true).at_least_once
    assert_equal file, theme_include('otherfile')[:file] # exists? = true
  end

  should 'include file from env theme' do
    def profile; p={}; def p.theme; 'my-theme'; end; p; end
    def environment; e={}; def e.theme; 'env-theme'; end; e; end
    def render(opt); opt; end
    File.stubs(:exists?).returns(false)
    file = Rails.root.join 'public/designs/themes/env-theme/afile.html.erb'
    assert_nil env_theme_include('afile') # exists? = false
    File.expects(:exists?).with(file).returns(true).at_least_once
    assert_equal file, env_theme_include('afile')[:file] # exists? = true
  end

  should 'include file from some theme' do
    def render(opt); opt; end
    File.stubs(:exists?).returns(false)
    file = Rails.root.join 'public/designs/themes/atheme/afile.html.erb'
    assert_nil from_theme_include('atheme', 'afile') # exists? = false
    File.expects(:exists?).with(file).returns(true).at_least_once
    assert_equal file, from_theme_include('atheme', 'afile')[:file] # exists? = true
  end

  should 'enable fullscreen buttons' do
    html = fullscreen_buttons("#article")
    assert html.include?("<script>fullscreenPageLoad('#article')</script>")
    assert html.include?("class=\"button with-text icon-fullscreen\"")
    assert html.include?("onClick=\"toggle_fullwidth('#article')\"")
  end

  should "return the related class string" do
    assert_equal "Clone Folder", label_for_clone_article(Folder.new)
    assert_equal "Clone Blog", label_for_clone_article(Blog.new)
    assert_equal "Clone Event", label_for_clone_article(Event.new)
    assert_equal "Clone Forum", label_for_clone_article(Forum.new)
    assert_equal "Clone Article", label_for_clone_article(TinyMceArticle.new)
  end

  protected
  include NoosferoTestHelper

  def capture
    yield
  end

  def concat(str)
    str
  end

end
