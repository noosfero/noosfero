require_relative '../test_helper'

class ProfileEditorControllerTest < ActionDispatch::IntegrationTest
  all_fixtures

  def setup
    @profile = create_user('default_user').person
    @user = @profile.user
    Environment.default.affiliate(@profile, [Environment::Roles.admin(Environment.default.id)] + Profile::Roles.all_roles(Environment.default.id))
    login_as_rails5('default_user')
  end
  attr_reader :profile, :user

  def test_index
    get profile_editor_index_path(profile.identifier)
    assert_template 'index'
    assert_response :success
    assert_not_nil assigns(:profile)
  end

  def test_should_present_pending_tasks_in_index
    ze = Profile['ze'] # a fixture >:-(
    t1 = ze.tasks.build; t1.save!
    t2 = ze.tasks.build; t2.save!
    get profile_editor_index_path(ze.identifier)
    assert_includes assigns(:pending_tasks), t1
    assert_includes assigns(:pending_tasks), t2
    assert_tag :tag => 'li', :attributes => { :class => "user-pending-tasks" }
  end

  should 'saving profile info' do
    person = profile
    post informations_profile_editor_index_path(profile.identifier), params: {:profile_data => { 'name' => 'new person', 'contact_information' => 'new contact information', 'address' => 'new address', 'sex' => 'female' }}
    assert_redirected_to :controller => 'profile_editor', :action => 'index'
    person = Person.find(person.id)
    assert_equal 'new person', person.name
    assert_equal 'new contact information', person.contact_information
    assert_equal 'new address', person.address
    assert_equal 'female', person.sex
  end

  should 'mass assign all environment configurable person fields' do
    person = profile
    post informations_profile_editor_index_path(profile.identifier), params: {:profile_data => {
      "nickname" => "ze", "description" => "Just a regular ze.", "contact_information" => "What?",
      "contact_phone" => "0551133445566", "cell_phone" => "0551188889999", "comercial_phone" => "0551144336655",
      "jabber_id" => "ze1234", "personal_website" => "http://ze.com.br", "sex" => "male", "birth_date" => "2014-06-04",
      "nationality" => "Brazilian", "country" => "BR", "state" => "DF", "city" => "Brasilia", "zip_code" => "70300-010",
      "address" => "Palacio do Planalto", "address_reference" => "Praca dos tres poderes", "district" => "DF",
      "schooling" => "Graduate", "schooling_status" => "Concluded", "formation" => "Engineerings",
      "area_of_study" => "Metallurgy", "professional_activity" => "Metallurgic", "organization" => "Metal Corp.",
      "organization_website" => "http://metal.com"
    }}

    assert_response :redirect
    assert_redirected_to :controller => 'profile_editor', :action => 'index'
  end

  should 'not permmit if not logged' do
    logout_rails5
    get profile_editor_index_path(profile.identifier)
    assert_response 302
  end

  should 'display categories to choose to associate profile' do
    cat1 = Environment.default.categories.build(:display_in_menu => true, :name => 'top category'); cat1.save!
    cat2 = Environment.default.categories.build(:display_in_menu => true, :name => 'sub category', :parent_id => cat1.id); cat2.save!
    person = profile
    get categories_profile_editor_index_path(profile.identifier)
    assert_response :success
    assert_template 'categories'
    assert_tag :tag => 'input', :attributes => {:name => 'profile_data[category_ids][]'}
    assert_tag :tag => 'a', :attributes => { :class => 'select-subcategory-link', :id => "select-category-#{cat1.id}-link" }
  end

  should 'save categorization of profile' do
    cat1 = Environment.default.categories.build(:name => 'top category'); cat1.save!
    cat2 = Environment.default.categories.build(:name => 'sub category', :parent_id => cat1.id); cat2.save!
    person = profile
    post categories_profile_editor_index_path(profile.identifier), params: {:profile_data => {:category_ids => [cat2.id]}}
    assert_response :redirect
    assert_redirected_to :controller => 'profile_editor', :action => 'index'
    assert_includes person.categories, cat2
  end

  should 'display profile categories' do
    profile_region = fast_create(Region, name: 'Profile Region')
    region = fast_create(Region, name: 'Region')
    category = fast_create(Category, name: 'Category')

    profile.region = profile_region
    profile.update_attributes(category_ids: [region.id, category.id])

    get categories_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'div', :content => profile_region.name,
               :ancestor => { :tag => 'div', :attributes => { :id => 'category-ajax-selector'}}
    assert_tag :tag => 'div', :content => region.name,
               :ancestor => { :tag => 'div', :attributes => { :id => 'category-ajax-selector'}}
    assert_tag :tag => 'div', :content => category.name,
               :ancestor => { :tag => 'div', :attributes => { :id => 'category-ajax-selector'}}
  end

  should 'display profile regions' do
    profile_region = fast_create(Region, name: 'Profile Region')
    region = fast_create(Region, name: 'Region')
    category = fast_create(Category, name: 'Category')

    profile.region = profile_region
    profile.update_attributes(category_ids: [region.id, category.id])

    get regions_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'div', :content => profile_region.name,
               :ancestor => { :tag => 'div', :attributes => { :id => 'category-ajax-selector'}}
    assert_tag :tag => 'div', :content => region.name,
               :ancestor => { :tag => 'div', :attributes => { :id => 'category-ajax-selector'}}
    !assert_tag :tag => 'div', :content => category.name,
               :ancestor => { :tag => 'div', :attributes => { :id => 'category-ajax-selector'}}
  end

  should 'filter html from person name' do
    name = "name <strong id='name_html_test'>with</strong> html"
    post informations_profile_editor_index_path(profile.identifier), params: {:profile_data => { :name => name }}
    assert_sanitized assigns(:profile).name
  end

  should 'filter html from organization fields' do
    org = fast_create(Organization)
    contact = "name <strong id='name_html_test'>with</strong> html"
    acronym = "name <strong id='name_html_test'>with</strong> html"
    legal_form = "name <strong id='name_html_test'>with</strong> html"
    economic_activity = "name <strong id='name_html_test'>with</strong> html"
    management_information = "name <strong id='name_html_test'>with</strong> html"
    name = "name <strong id='name_html_test'>with</strong> html"

    post informations_profile_editor_index_path(org.identifier), params: {:profile_data => { :name => name, :contact_person => contact, :acronym => acronym, :legal_form => legal_form, :economic_activity => economic_activity, :management_information =>  management_information}}

    assert_sanitized assigns(:profile).contact_person
    assert_sanitized assigns(:profile).acronym
    assert_sanitized assigns(:profile).legal_form
    assert_sanitized assigns(:profile).economic_activity
    assert_sanitized assigns(:profile).management_information
  end

  should 'saving profile organization_info' do
    org = fast_create(Organization)
    post informations_profile_editor_index_path(org.identifier), params: {:profile_data => { :contact_person => 'contact person' }}
    assert_equal 'contact person', Organization.find(org.id).contact_person
  end

  should 'show contact_phone field on edit enterprise' do
    org = fast_create(Enterprise)
    Enterprise.any_instance.expects(:active_fields).returns(['contact_phone']).at_least_once
    get informations_profile_editor_index_path(org.identifier)
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_phone]' }
  end

  should 'save community description' do
    org = fast_create(Community)
    post informations_profile_editor_index_path(org.identifier), params: {:profile_data => { :description => 'my description' }}
    assert_equal 'my description', Organization.find(org.id).description
  end

  should 'show community description' do
    org = fast_create(Community)
    Community.any_instance.expects(:active_fields).returns(['description']).at_least_once
    get informations_profile_editor_index_path(org.identifier)
    assert_tag :tag => 'textarea', :attributes => { :name => 'profile_data[description]' }
  end

  should 'not show enterprise description' do
    org = fast_create(Enterprise)
    get informations_profile_editor_index_path(org.identifier)
    !assert_tag :tag => 'textarea', :attributes => { :name => 'profile_data[description]' }
  end

  should 'save organization contact_person' do
    org = fast_create(Organization)
    post informations_profile_editor_index_path(org.identifier), params: {:profile_data => { :contact_person => 'my contact' }}
    assert_equal 'my contact', Organization.find(org.id).contact_person
  end

  should 'save enterprise contact_person' do
    org = fast_create(Enterprise)
    post informations_profile_editor_index_path(org.identifier), params: {:profile_data => { :contact_person => 'my contact' }}
    assert_equal 'my contact', Enterprise.find(org.id).contact_person
  end

  should 'show field values on edit community info' do
    Community.any_instance.expects(:active_fields).returns(['contact_person']).at_least_once
    org = fast_create(Community)
    org.contact_person = 'my contact'
    org.save!
    get informations_profile_editor_index_path(org.identifier)
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_person]', :value => 'my contact' }
  end

  should 'mass assign all environment configurable community fields' do
    cmm = fast_create(Community)

    post informations_profile_editor_index_path(cmm.identifier), params: {:profile_data => { "name" => "new name", "display_name" => "N&w N@me", "description"=>"We sell food and other stuff.", "contact_person"=>"Joseph of the Jungle", "contact_email"=>"sac@company.net", "contact_phone"=>"0551133445566", "legal_form"=>"New Name corp.", "economic_activity"=>"Food", "management_information"=>"No need for that here.", "address"=>"123, baufas street", "address_reference"=>"Next to baufas house", "district"=>"DC", "zip_code"=>"123456", "city"=>"Whashington", "state"=>"DC", "country"=>"US", "tag_list"=>"food, corporations", "language"=>"English" }}

    assert_response :redirect
    assert_redirected_to :controller => 'profile_editor', :action => 'index'
  end

  should 'show field values on edit enterprise info' do
    Enterprise.any_instance.expects(:active_fields).returns(['contact_person']).at_least_once
    org = fast_create(Enterprise)
    org.contact_person = 'my contact'
    org.save!
    get informations_profile_editor_index_path(org.identifier)
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[contact_person]', :value => 'my contact' }
  end

  should 'mass assign all environment configurable enterprise fields' do
    enterprise = fast_create(Enterprise)

    post informations_profile_editor_index_path(enterprise.identifier), params: {:profile_data => { "name"=>"Enterprise", "display_name"=>"Enterprise name", "business_name"=>"Enterprise", "description"=>"Hello IT.", "contact_person"=>"Joseph", "contact_email"=>"joe@enterprise.net", "contact_phone"=>"0551133445566", "legal_form"=>"Enterprise corp.", "economic_activity"=>"Food", "management_information"=>"None.", "address"=>"123, baufas street", "address_reference"=>"Next to baufas house", "district"=>"DC", "zip_code"=>"123456", "city"=>"Washington", "state"=>"DC", "country"=>"US", "tag_list"=>"food, corporations", "organization_website"=>"http://enterprise.net", "historic_and_current_context"=>"Historic.", "activities_short_description"=>"Activies.", "acronym"=>"E", "foundation_year"=>"1995",}}

    assert_response :redirect
    assert_redirected_to :controller => 'profile_editor', :action => 'index'
  end

  should 'show error messages for invalid foundation_year' do
    org = fast_create(Community)
    post informations_profile_editor_index_path(org.identifier), params: {:profile_data => { :foundation_year => 'aaa' }}
    assert_tag :tag => 'div', :attributes => { :id => 'errorExplanation' }
  end

  should 'edit enterprise' do
    ent = fast_create(Enterprise)
    get informations_profile_editor_index_path(ent.identifier)
    assert_response :success
  end

  should 'back when update community info fail' do
    org = fast_create(Community)
    Community.any_instance.expects(:update!).raises(ActiveRecord::RecordInvalid)
    post informations_profile_editor_index_path(org.identifier)

    assert_template 'informations'
    assert_response :success
  end

  should 'back when update enterprise info fail' do
    org = fast_create(Enterprise)

    Enterprise.any_instance.expects(:update!).raises(ActiveRecord::RecordInvalid)
    post informations_profile_editor_index_path(org.identifier)
    assert_template 'informations'
    assert_response :success
  end

  should 'show image field on profile informations' do
    get informations_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[image_builder][uploaded_data]' }
  end

  should 'show categories links on catogories page' do
    cat1 = Environment.default.categories.create!(:display_in_menu => true, :name => 'top category')
    cat2 = Environment.default.categories.create!(:display_in_menu => true, :name => 'sub category', :parent_id => cat1.id)
    person = create_user('testuser').person
    get categories_profile_editor_index_path('testuser')
    assert_tag :tag => 'a', :attributes => { :class => 'select-subcategory-link', :id => "select-category-#{cat1.id}-link" }
  end

  should 'render person partial' do
    person = profile
    Person.any_instance.expects(:active_fields).returns(['contact_phone', 'nickname']).at_least_once
    get informations_profile_editor_index_path(person.identifier)
    person.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'display only active person fields' do
    Person.any_instance.expects(:active_fields).returns(['cell_phone']).at_least_once

    get informations_profile_editor_index_path(profile.identifier)

    assert_tag :tag => 'input', :attributes => { :name => "profile_data[cell_phone]" }
    !assert_tag :tag => 'input', :attributes => { :name => "profile_data[comercial_phone]" }
  end

  should 'be able to upload an image' do
    assert_nil profile.image
    post informations_profile_editor_index_path(profile.identifier), params: {:profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }}
    assert_not_nil assigns(:profile).image
  end

  should 'display closed attribute for communities when it is set' do
    org = fast_create(Community)
    org.closed = true
    org.save!

    get privacy_profile_editor_index_path(org.identifier)

    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true', :checked => 'checked' }
    !assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false', :checked =>  'checked' }
  end

  should 'display closed attribute for communities when it is set to false' do
    org = fast_create(Community)

    [false, nil].each do |value|
      org.closed = value
      org.save!
      get privacy_profile_editor_index_path(org.identifier)
      !assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true', :checked => 'checked' }
      assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false', :checked => 'checked' }
    end
  end

  should 'set closed attribute correctly' do
    org = fast_create(Organization)
    org.closed = false
    org.save!

    post privacy_profile_editor_index_path(org.identifier), params: {:profile_data => { :closed => 'true' }}
    org.reload
    assert org.closed
  end

  should 'unset closed attribute correctly' do
    org = fast_create(Organization)
    org.closed = true
    org.save!

    post privacy_profile_editor_index_path(org.identifier), params: {:profile_data => { :closed => 'false' }}
    org.reload
    refute org.closed
  end

  should 'not display option to close when it is enterprise' do
    org = fast_create(Enterprise)
    get privacy_profile_editor_index_path(org.identifier)

    !assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true' }
    !assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false' }
  end

  should 'display option to close when it is community' do
    org = fast_create(Community)
    get privacy_profile_editor_index_path(org.identifier)

    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'true' }
    assert_tag :tag => 'input', :attributes => { :type => 'radio', :name => 'profile_data[closed]', :value => 'false' }
  end

  should 'render enterprise partial' do
    ent = fast_create(Enterprise)
    Enterprise.any_instance.expects(:active_fields).returns(['contact_phone', 'contact_person', 'contact_email']).at_least_once
    get informations_profile_editor_index_path(ent.identifier)
    ent.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'render community partial' do
    community = fast_create(Community)
    Community.any_instance.expects(:active_fields).returns(['contact_person', 'language']).at_least_once
    get informations_profile_editor_index_path(community.identifier)
    community.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'show task if user has permission' do
    user1 = profile
    user2 = create_user('usertwo').person
    AddFriend.create!(:person => user1, :friend => user2)
    login_as_rails5('usertwo')
    get profile_editor_index_path('usertwo')
    assert_tag :tag => 'div', :attributes => { :id => 'pending-tasks' }
  end

  should 'not show task if user has no permission' do
    user1 = profile
    community = fast_create(Community)
    user2 = create_user('usertwo').person
    task = AddMember.create!(person: user1, organization: community)
    give_permission(user2, 'invite_members', community)
    login_as_rails5('usertwo')
    get profile_editor_index_path('usertwo')
    !assert_tag :tag => 'div', :attributes => { :class => 'pending-tasks' }
  end

  should 'limit task list' do
    user2 = create_user('usertwo').person
    6.times { AddFriend.create!(:person => create_user.person, :friend => user2) }
    login_as_rails5('usertwo')
    get profile_editor_index_path('usertwo')
    # assert_select '.pending-tasks > ul > li', 5
    assert_tag :tag => 'div', :attributes => { :id => 'pending-tasks' }, :content => '6'
  end


  should 'display task count in task list' do
    user2 = create_user('usertwo').person
    6.times { AddFriend.create!(:person => create_user.person, :friend => user2) }
    login_as_rails5('usertwo')
    get profile_editor_index_path('usertwo')
    assert_response :success

    # the following assertions were commented due to the current inexistence of
    # a html field with this behavior
    #
    # assert_select '.pending-tasks h2' do |elements|
    #   assert_match /6/, elements.first.content
    # end

    assert_tag :tag => 'div', :attributes => { :id => 'pending-tasks' }
  end

  should 'show favorite enterprises button for person' do
    get profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'a', :content => 'Favorite Enterprises'
  end

  should 'not show favorite enterprises button for organization' do
    org = fast_create(Organization)
    get profile_editor_index_path(org.identifier)
    !assert_tag :tag => 'a', :content => 'Favorite Enterprises'
  end

  should 'link to mailconf' do
    MailConf.expects(:enabled?).returns(true).at_least_once
    get profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/mailconf" }
  end

  should 'not link to mailconf for organizations' do
    MailConf.stubs(:enabled?).returns(true)
    org = fast_create(Organization)
    get profile_editor_index_path(org.identifier)
    !assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{org.identifier}/mailconf" }
  end

  should 'not link to mailconf if mail not enabled' do
    MailConf.expects(:enabled?).returns(false).at_least_once
    get profile_editor_index_path(profile.identifier)
    !assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/mailconf" }
  end

  should 'link to enable enterprise' do
    ent = fast_create(Enterprise, :enabled => false)
    get profile_editor_index_path(ent.identifier)
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{ent.identifier}/profile_editor/enable" }
  end

  should 'link to disable enterprise' do
    ent = fast_create(Enterprise, :enabled => true)
    get profile_editor_index_path(ent.identifier)
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{ent.identifier}/profile_editor/disable" }
  end

  should 'not link to enable/disable for non enterprises' do
    ent = fast_create(Organization, :enabled => true)
    get profile_editor_index_path(ent.identifier)
    !assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{ent.identifier}/profile_editor/disable" }
  end

  should 'request enable enterprise confirmation' do
    ent = fast_create(Enterprise, :enabled => false)
    get enable_profile_editor_index_path(ent.identifier)
    assert_tag :tag => 'form', :attributes => { :action => "/myprofile/#{ent.identifier}/profile_editor/enable", :method => 'post' }
  end

  should 'enable enterprise after confirmation' do
    ent = fast_create(Enterprise, :enabled => false)
    post enable_profile_editor_index_path(ent.identifier), params: {:confirmation => 1}
    assert assigns(:to_enable).enabled?
  end

  should 'not enable enterprise without confirmation' do
    ent = fast_create(Enterprise, :enabled => false)
    post enable_profile_editor_index_path(ent.identifier)
    refute assigns(:to_enable).enabled?
  end

  should 'disable enterprise after confirmation' do
    ent = fast_create(Enterprise, :enabled => true)
    post disable_profile_editor_index_path(ent.identifier), params: {:confirmation => 1}
    refute assigns(:to_disable).enabled?
  end

  should 'not disable enterprise without confirmation' do
    ent = fast_create(Enterprise, :enabled => true)
    post disable_profile_editor_index_path(ent.identifier)
    assert assigns(:to_disable).enabled?
  end

  should 'update categories' do
    env = Environment.default
    top = env.categories.create!(:display_in_menu => true, :name => 'Top-Level category')
    c1  = env.categories.create!(:display_in_menu => true, :name => "Test category 1", :parent_id => top.id)
    c2  = env.categories.create!(:display_in_menu => true, :name => "Test category 2", :parent_id => top.id)
    #get :update_categories, :profile => profile.identifier, :category_id => top.id, xhr: true
    get update_categories_profile_editor_index_path(profile.identifier), params: {:category_id => top.id}, xhr: true
    assert_template 'shared/update_categories'
    assert_equal top, assigns(:current_category)
    assert_equivalent [c1, c2], assigns(:categories)
  end

  should 'display footer edit screen' do

    person = profile
    person.custom_header = 'my custom header'
    person.custom_footer = 'my custom footer'
    person.save!

    get header_footer_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'textarea', :content => /my custom header/
    assert_tag :tag => 'textarea', :content => /my custom footer/
  end

  should 'render TinyMce Editor for header and footer' do
    get header_footer_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'textarea', :attributes => { :id => 'custom_header', :class => Article::Editor::TINY_MCE }
    assert_tag :tag => 'textarea', :attributes => { :id => 'custom_footer', :class => Article::Editor::TINY_MCE }
  end

  should 'save footer and header' do
    person = profile
    post header_footer_profile_editor_index_path(profile.identifier), params: {:custom_header => 'new header', :custom_footer => 'new footer'}
    person = Person.find(person.id)
    assert_equal 'new header', person.custom_header
    assert_equal 'new footer', person.custom_footer
  end

  should 'save header and footer even if model is invalid' do
    person = profile
    person.sex = nil; person.save!
    person.environment.custom_person_fields = {'sex' => {'required' => 'true', 'active' => 'true'} }; person.environment.save!

    post header_footer_profile_editor_index_path(profile.identifier), params: {:custom_header => 'new header', :custom_footer => 'new footer'}
    person = Person.find(person.id)
    assert_equal 'new header', person.custom_header
    assert_equal 'new footer', person.custom_footer
  end

  should 'go back to editor after saving header/footer' do
    post header_footer_profile_editor_index_path(profile.identifier), params: {:custom_header => 'new header', :custom_footer => 'new footer'}
    assert_redirected_to :action => 'index'
  end

  should 'point to header/footer editing in control panel' do
    get profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/profile_editor/header_footer" }
  end

  should 'not display header/footer button to enterprises if the environment disabled it' do
    env = Environment.default
    env.enable('disable_header_and_footer')
    env.save!

    enterprise = fast_create(Enterprise)

    u = create_user_with_permission('test_user', 'edit_profile', enterprise)
    login_as_rails5('test_user')

    get profile_editor_index_path(enterprise.identifier)
    !assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{enterprise.identifier}/profile_editor/header_footer" }
  end

  should 'display header/footer button to enterprises if the environment disabled it but user is admin' do
    env = Environment.default
    env.enable('disable_header_and_footer')
    env.save!

    enterprise = fast_create(Enterprise)

    Person.any_instance.expects(:is_admin?).returns(true).at_least_once

    get profile_editor_index_path(enterprise.identifier)
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{enterprise.identifier}/profile_editor/header_footer" }
  end

  should 'display categories if environment disable_categories disabled' do
    Environment.any_instance.stubs(:enabled?).with(anything).returns(false)
    get categories_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'h1', :content => /Categories of Interest/
  end

  should 'show a e-mail field in profile editor' do
    get informations_profile_editor_index_path(profile.identifier)

    assert_tag :tag => 'input',
               :attributes => { :name=>'profile_data[email]', :value => profile.email }
  end

  should 'display enable contact us for enterprise' do
    org = fast_create(Enterprise)
    get informations_profile_editor_index_path(org.identifier)
    assert_tag :tag => 'input', :attributes => {:name => 'profile_data[enable_contact_us]', :type => 'checkbox'}
  end

  should 'display link to CMS' do
    get informations_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/default_user/cms' }
  end

  should 'display email template link for organizations in control panel' do
    profile = fast_create(Organization)
    get informations_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/profile_email_templates" }
  end

  should 'not display email template link in control panel for person' do
    get informations_profile_editor_index_path(profile.identifier)
    !assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/email_templates" }
  end

  should 'offer to create blog in control panel' do
    get informations_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/default_user/cms/new?type=Blog" }
  end

  should 'offer to config blog in control panel' do
    profile.articles << Blog.new(:name => 'My blog', :profile => profile)
    get informations_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/edit/#{profile.blog.id}" }
  end

  should 'not show select preferred domain if not enabled in environment' do
    profile.environment.custom_person_fields = {}; profile.environment.save!

    get informations_profile_editor_index_path(profile.identifier)
    !assert_tag :tag => 'select', :attributes => { :name => 'profile_data[preferred_domain_id]' }
  end

  should 'be able to choose preferred domain' do
    profile.domains << Domain.new(:name => 'myowndomain.net')
    profile.environment.domains << Domain.new(:name => 'myenv.net')

    profile.environment.custom_person_fields = {'preferred_domain' => {'required' => 'true', 'active' => 'true'} }; profile.environment.save!
    ActionDispatch::Request.any_instance.stubs(:host).returns(profile.hostname)

    get informations_profile_editor_index_path(profile.identifier)

    assert_tag :tag => 'select', :attributes => { :name => 'profile_data[preferred_domain_id]' }, :descendant => { :tag => "option", :content => 'myowndomain.net' }
    assert_tag :tag => 'select', :attributes => { :name => 'profile_data[preferred_domain_id]' }, :descendant => { :tag => "option", :content => 'myenv.net' }

    post informations_profile_editor_index_path(profile.identifier), params: {:profile_data => { :preferred_domain_id => profile.domains.first.id.to_s }}

    assert_equal 'myowndomain.net', Profile.find(profile.id).preferred_domain.name
  end

  should 'be able to set no preferred domain at all' do
    profile.environment.custom_person_fields = {'preferred_domain' => {'required' => 'true', 'active' => 'true'} }; profile.environment.save!

    profile.domains << Domain.new(:name => 'myowndomain.net')
    profile.environment.domains << Domain.new(:name => 'myenv.net')

    ActionDispatch::Request.any_instance.stubs(:host).returns(profile.hostname)
    get informations_profile_editor_index_path(profile.identifier)

    assert_tag :tag => "select", :attributes => { :name => 'profile_data[preferred_domain_id]'}, :descendant => { :tag => 'option', :content => '&lt;Select domain&gt;', :attributes => { :value => '' } }

    post informations_profile_editor_index_path(profile.identifier), params: {:profile_data => { :preferred_domain_id => '' }}
    assert_nil Profile.find(profile.id).preferred_domain
  end

  should 'not be able to upload an image bigger than max size' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] + 1024)
    person = profile
    assert_nil person.image
    post informations_profile_editor_index_path(person.identifier), params: {:profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }}
    assert_nil person.image
  end

  should 'display error message when image has more than max size' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] + 1024)
    post informations_profile_editor_index_path(profile.identifier), params: {:profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }}
    assert_tag :tag => 'div', :attributes => { :class => 'errorExplanation', :id => 'errorExplanation' }
  end

  should 'not display error message when image has less than max size' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] - 1024)
    post informations_profile_editor_index_path(profile.identifier), params: {:profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }}
    !assert_tag :tag => 'div', :attributes => { :class => 'errorExplanation', :id => 'errorExplanation' }
  end

  should 'not redirect when some file has errors' do
    Image.any_instance.stubs(:size).returns(Image.attachment_options[:max_size] + 1024)
    post informations_profile_editor_index_path(profile.identifier), params: {:profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') } }}
    assert_response :success
    assert_template 'informations'
  end

  should 'not display form for enterprise activation if disabled in environment' do
    env = Environment.default
    env.disable('enterprise_activation')
    env.save!

    get profile_editor_index_path(profile.identifier)
    !assert_tag :tag => 'div', :attributes => { :id => 'activation_enterprise' }, :descendant => {:tag => 'form', :attributes => {:action => '/account/activation_question'}}
  end

  should 'display form for enterprise activation if enabled on environment' do
    env = Environment.default
    env.enable('enterprise_activation')
    env.save!

    get profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'div', :attributes => { :id => 'activation_enterprise' }, :descendant => {:tag => 'form', :attributes => {:action => '/account/activation_question'}}
  end

  should 'not display enterprise activation to enterprises' do
    env = Environment.default
    env.enable('enterprise_activation')
    env.save!

    enterprise = fast_create(Enterprise)
    enterprise.add_admin(profile)

    get profile_editor_index_path(enterprise.identifier)
    !assert_tag :tag => 'div', :attributes => { :id => 'activation_enterprise' }, :descendant => {:tag => 'form', :attributes => {:action => '/account/activation_question'}}
  end

  should 'have url field for identifier when environment allows' do
    c = fast_create(Community)
    env = c.environment
    env.enable('enable_profile_url_change')
    env.save!

    get informations_profile_editor_index_path(c.identifier)
    assert_tag :tag => 'div',
               :attributes => { :class => 'formfield type-text' },
               :content => /https?:\/\/#{c.environment.default_hostname}\//,
               :descendant => {:tag => 'input', :attributes => {:id => 'profile_data_identifier'} }
  end

  should 'not have url field for identifier when environment not allows' do
    c = fast_create(Community)
    env = c.environment
    env.disable('enable_profile_url_change')
    env.save!

    get informations_profile_editor_index_path(c.identifier)
    !assert_tag :tag => 'div',
               :attributes => { :class => 'formfield type-text' },
               :content => /https?:\/\/#{c.environment.default_hostname}\//,
               :descendant => {:tag => 'input', :attributes => {:id => 'profile_data_identifier'} }
  end

  should 'redirect to new url when is changed' do
    c = fast_create(Community)
    post informations_profile_editor_index_path(c.identifier), params: {:profile_data => {:identifier => 'new_address'}}
    assert_response :redirect
    assert_redirected_to :action => 'index', :profile => 'new_address'
  end

  should 'not crash if identifier is left blank' do
    c = fast_create(Community)
    assert_nothing_raised do
      post informations_profile_editor_index_path(c.identifier), params: {:profile_data => {:identifier => ''}}
    end
  end

  should 'show active fields when edit community' do
    env = Environment.default
    env.custom_community_fields = {
      'contact_email' => {'active' => 'true', 'required' => 'false'},
      'contact_phone' => {'active' => 'true', 'required' => 'false'}
    }
    env.save!
    community = fast_create(Community)

    get informations_profile_editor_index_path(community.identifier)

    community.active_fields.each do |field|
      assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'not show disabled fields when edit community' do
    env = Environment.default
    env.custom_community_fields = {
      'contact_email' => {'active' => 'false', 'required' => 'false'},
      'contact_phone' => {'active' => 'false', 'required' => 'false'}
    }
    env.save!
    community = fast_create(Community)

    get informations_profile_editor_index_path(community.identifier)

    (Community.fields - community.active_fields).each do |field|
      !assert_tag :tag => 'input', :attributes => { :name => "profile_data[#{field}]" }
    end
  end

  should 'show profile nickname on title' do
    profile.update(:nickname => 'my nick')
    get profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'h1', :attributes => { :class => 'block-title'}, :descendant => {
      :tag => 'span', :attributes => { :class => 'control-panel-title' }, :content => 'my nick'
    }
  end

  should 'show profile name on title when no nickname' do
    get profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'h1', :attributes => { :class => 'block-title'}, :descendant => {
      :tag => 'span', :attributes => { :class => 'control-panel-title' }, :content => profile.identifier
    }
  end

  should 'render destroy_profile template' do
    community = fast_create(Community)
    get destroy_profile_profile_editor_index_path(community.identifier)
    assert_template 'destroy_profile'
  end

  should 'not be able to destroy profile if forbid_destroy_profile is enabled' do
    environment = Environment.default
    user = create_user('user').person
    logout_rails5
    login_as_rails5('user')
    environment.enable('forbid_destroy_profile')
    assert_no_difference 'Profile.count' do
      post destroy_profile_profile_editor_index_path(user.identifier)
    end
  end

  should 'display destroy_profile button' do
    environment = Environment.default
    user = create_user_with_permission('user', 'destroy_profile')
    login_as_rails5('user')
    community = fast_create(Community)
    community.add_admin(user)
    get informations_profile_editor_index_path(community.identifier)
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{community.identifier}/profile_editor/destroy_profile" }
  end

  should 'not display destroy_profile button' do
    environment = Environment.default
    environment.enable('forbid_destroy_profile')
    environment.save!
    user = create_user_with_permission('user', 'destroy_profile')
    login_as_rails5('user')
    community = fast_create(Community)
    community.add_admin(user)
    get informations_profile_editor_index_path(community.identifier)
    !assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{community.identifier}/profile_editor/destroy_profile" }
  end

  should 'be able to destroy a person' do
    person = fast_create(Person)

    assert_difference 'Person.count', -1 do
      post destroy_profile_profile_editor_index_path(person.identifier)
    end
  end

  should 'be able to destroy communities' do
    community = fast_create(Community)

    person = create_user('foo').person
    community.add_admin(person)

    assert_difference 'Community.count', -1 do
      post destroy_profile_profile_editor_index_path(community.identifier)
    end
  end

  should 'not be able to destroy communities if is a regular member' do
    community = fast_create(Community)
    community.add_admin(fast_create(Person)) # first member is admin by default

    person = create_user('foo').person
    community.add_member(person)

    logout_rails5
    login_as_rails5 'foo'
    assert_difference 'Community.count', 0 do
      post destroy_profile_profile_editor_index_path(community.identifier)
    end
  end

  should 'be able to destroy enterprise' do
    enterprise = fast_create(Enterprise)

    person = create_user('foo').person
    enterprise.add_admin(person)

    assert_difference 'Enterprise.count', -1 do
      post destroy_profile_profile_editor_index_path(enterprise.identifier)
    end
  end

  should 'not be able to destroy enterprise if is a regular member' do
    enterprise = fast_create(Enterprise)
    enterprise.add_member(create_user.person) # first member is admin by default

    person = create_user('foo').person
    enterprise.add_member(person)

    logout_rails5
    login_as_rails5('foo')
    assert_difference 'Enterprise.count', 0 do
      post destroy_profile_profile_editor_index_path(enterprise.identifier)
    end
  end

  should 'have welcome_page only for template' do
    controller =  ProfileEditorController.new
    organization = fast_create(Organization, :is_template => false)

    controller.stubs(:profile).returns(organization)
    refute controller.send(:has_welcome_page)

    organization = fast_create(Organization, :is_template => true)
    controller.stubs(:profile).returns(organization)
    assert controller.send(:has_welcome_page)

    person = fast_create(Person, :is_template => false)
    controller.stubs(:profile).returns(person)
    refute controller.send(:has_welcome_page)

    person = fast_create(Person, :is_template => true)
    controller.stubs(:profile).returns(person)
    assert controller.send(:has_welcome_page)
  end

  should 'not be able to access welcome_page if profile does not has_welcome_page' do
    get welcome_page_profile_editor_index_path(fast_create(Profile).identifier)
    assert_response :forbidden
  end

  should 'create welcome_page with public false by default' do
    get welcome_page_profile_editor_index_path(fast_create(Person, :is_template => true).identifier)
    refute assigns(:welcome_page).published
  end

  should 'update welcome page and redirect to index' do
    person_template = create_user('person_template').person
    person_template.is_template = true

    welcome_page = fast_create(TextArticle, :body => 'Initial welcome page')
    person_template.welcome_page = welcome_page
    person_template.save!
    welcome_page.profile = person_template
    welcome_page.save!
    new_content = 'New welcome page'

    post welcome_page_profile_editor_index_path(person_template.identifier), params: {:welcome_page => {:body => new_content}}
    assert_redirected_to :action => 'index'

    welcome_page.reload
    assert_equal new_content, welcome_page.body
  end

  should 'display plugins buttons on the control panel' do
    class Plugin1 < Noosfero::Plugin
      class Button1 < ControlPanel::Entry
        class << self
          def name
            "Button 1"
          end

          def section
            'others'
          end

          def url(profile)
            'button1_url'
          end

          def custom_keywords
            ['button1_keyword']
          end

          def options
            {:data => {extra: true}}
          end
        end
      end

      class Button2 < ControlPanel::Entry
        class << self
          def name
            "Button 2"
          end

          def section
            'others'
          end

          def url(profile)
            'button2_url'
          end

          def custom_keywords
            ['button2_keyword']
          end
        end
      end

      def control_panel_entries
        [Button1, Button2]
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s])
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([Plugin1.new])

    get profile_editor_index_path(profile.identifier)

    assert_tag :tag => 'a', :content => 'Button 1', :attributes => {:class => /entry/, :href => /button1_url/, :'data-extra' => true, :'data-keywords' => /button1-keyword/}
    assert_tag :tag => 'a', :content => 'Button 2', :attributes => {:class => /entry/, :href => /button2_url/, :'data-keywords' => /button2-keyword/}
  end

  should 'add extra content provided by plugins on informations' do
    class TestProfileEditPlugin < Noosfero::Plugin
      def profile_editor_informations
        "<input id='field_added_by_plugin' value='value_of_field_added_by_plugin'/>".html_safe
      end
    end
    Noosfero::Plugin.stubs(:all).returns([TestProfileEditPlugin.to_s])

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestProfileEditPlugin.new])

    get informations_profile_editor_index_path(profile.identifier)

    assert_tag :tag => 'input', :attributes => {:id => 'field_added_by_plugin', :value => 'value_of_field_added_by_plugin'}
  end

  should 'add extra content with block provided by plugins on edit' do
    class TestProfileEditPlugin < Noosfero::Plugin
      def profile_editor_informations
        lambda do
          (render html: "<input id='field_added_by_plugin' value='value_of_field_added_by_plugin'/>".html_safe).html_safe
        end
      end
    end
    Noosfero::Plugin.stubs(:all).returns([TestProfileEditPlugin.to_s])

    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestProfileEditPlugin.new])

    get informations_profile_editor_index_path(profile.identifier)

    assert_tag :tag => 'input', :attributes => {:id => 'field_added_by_plugin', :value => 'value_of_field_added_by_plugin'}
  end

  should 'show image upload field from profile editor' do
    env = Environment.default
    env.custom_person_fields = { }
    env.save!
    get informations_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'input', :attributes => { :name => 'profile_data[image_builder][uploaded_data]' }
    assert_tag :tag => 'div', :attributes => { :id => 'change-image' }
  end

  should 'add extra content on person info from plugins' do
    class Plugin1 < Noosfero::Plugin
      def profile_info_extra_contents
        proc {"<strong>Plugin1 text</strong>".html_safe}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def profile_info_extra_contents
        proc {"<strong>Plugin2 text</strong>".html_safe}
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin2.to_s])

    Environment.default.enable_plugin(Plugin1)
    Environment.default.enable_plugin(Plugin2)

    get informations_profile_editor_index_path(profile.identifier)

    assert_tag :tag => 'strong', :content => 'Plugin1 text'
    assert_tag :tag => 'strong', :content => 'Plugin2 text'
  end

  should 'add extra content on organization info from plugins' do
    class Plugin1 < Noosfero::Plugin
      def profile_info_extra_contents
        proc {"<strong>Plugin1 text</strong>".html_safe}
      end
    end
    class Plugin2 < Noosfero::Plugin
      def profile_info_extra_contents
        proc {"<strong>Plugin2 text</strong>".html_safe}
      end
    end
    Noosfero::Plugin.stubs(:all).returns([Plugin1.to_s, Plugin2.to_s])

    Environment.default.enable_plugin(Plugin1)
    Environment.default.enable_plugin(Plugin2)
    organization = fast_create(Community)

    get informations_profile_editor_index_path(organization.identifier)

    assert_tag :tag => 'strong', :content => 'Plugin1 text'
    assert_tag :tag => 'strong', :content => 'Plugin2 text'
  end

  should 'see is_template check_box' do
    give_permission(profile, 'manage_environment_templates', profile.environment)
    get informations_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'input', :attributes => {:name => 'profile_data[is_template]'}
  end

  should 'not see is_template check_box' do
    another_user = create_user('another_user').person
    login_as_rails5('another_user')
    get informations_profile_editor_index_path(profile.identifier)
    !assert_tag :tag => 'input', :attributes => {:name => 'profile_data[is_template]'}
  end

  should 'display select to change redirection after login if enabled' do
    e = Environment.default
    e.enable('allow_change_of_redirection_after_login')
    e.save

    get preferences_profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'select', :attributes => {:id => 'profile_data_redirection_after_login'}
  end

  should 'not display select to change redirection after login if not enabled' do
    e = Environment.default
    e.disable('allow_change_of_redirection_after_login')
    e.save

    get preferences_profile_editor_index_path(profile.identifier)
    !assert_tag :tag => 'select', :attributes => {:id => 'profile_data_redirection_after_login'}
  end

  should 'uncheck all field privacy fields' do
    person = profile
    assert_equal({}, person.fields_privacy)
    post informations_profile_editor_index_path(profile.identifier), params: {:profile_data => {}}
    assert_equal({}, person.reload.fields_privacy)
  end

  should 'not redirect if the profile_hostname is the same as environment hostname' do
    Person.any_instance.stubs(:hostname).returns('hostname.org')
    Environment.any_instance.stubs(:default_hostname).returns('hostname.org')

    ActionDispatch::Request.any_instance.stubs(:host).returns('hostname.org')
    get profile_editor_index_path(profile.identifier)

    assert_response :success
  end

  should 'show head and footer for admin' do
    login_as_rails5('default_user')
    get profile_editor_index_path(profile.identifier)
    assert_tag :tag => 'div', :descendant => { :tag => 'a', :content => 'Header and Footer' }
  end

  should 'not display header and footer for user when feature is enable' do
    user = create_user('user').person
    login_as_rails5('user')
    profile.environment.enable('disable_header_and_footer')
    get profile_editor_index_path(user.identifier)
    !assert_tag :tag => 'div', :descendant => { :tag => 'a', :content => 'Header and Footer' }
  end

  should 'display header and footer for user when feature is disabled ' do
    user = create_user('user').person
    login_as_rails5('user')
    profile.environment.disable('disable_header_and_footer')
    get profile_editor_index_path(user.identifier)
    assert_tag :tag => 'div', :descendant => { :tag => 'a', :content => 'Header and Footer' }
  end

  should 'user cant edit header and footer if environment dont permit' do
    environment = Environment.default
    environment.settings[:disable_header_and_footer_enabled] = true
    environment.save!

    user = create_user('user').person
    logout_rails5
    login_as_rails5('user')

    get header_footer_profile_editor_index_path(user.identifier)
    assert_response :redirect
  end

  should 'admin can edit header and footer if environment dont permit' do
    user = create_user('user').person

    environment = Environment.default
    environment.add_admin(user)
    environment.settings[:disable_header_and_footer_enabled] = true
    environment.save!

    login_as_rails5('user')

    get header_footer_profile_editor_index_path(user.identifier)
    assert_response :success
  end

  should 'not display button to manage roles on control panel of person' do
    get profile_editor_index_path(profile.identifier)
    !assert_tag :tag => 'a', :attributes => { :href => "/myprofile/default_user/profile_roles" }
  end

  should 'save profile admin option to receive email for every task' do
    comm = fast_create(Community)
    assert comm.profile_admin_mail_notification
    post privacy_profile_editor_index_path(comm.identifier), params: {:profile_data => { :profile_admin_mail_notification => '0' }}
    refute comm.reload.profile_admin_mail_notification
  end

  should 'not display option to change identifier for person' do
    get informations_profile_editor_index_path(profile.identifier)
    assert_select '#profile-identifier-formitem', 0
  end

  should 'display option to change identifier for person when allowed by environment' do
    profile.environment.enable(:enable_profile_url_change)
    get informations_profile_editor_index_path(profile.identifier)
    assert_select '#profile-identifier-formitem', 1
  end

  should 'response of search_tags be json' do
    get search_tags_profile_editor_index_path(profile.identifier), params: {:term => 'linux'}
    assert_equal 'application/json', @response.content_type
  end

  should 'return empty json if does not find tag' do
    get search_tags_profile_editor_index_path(:profile => profile.identifier), params: {:term => 'linux'}
    assert_equal "[]", @response.body
  end

  should 'return tags found' do
    a = profile.articles.create(:name => 'blablabla')
    a.tags.create! name: 'linux'
    get search_tags_profile_editor_index_path(profile.identifier), params: {:term => 'linux'}
    assert_equal '[{"label":"linux","value":"linux"}]', @response.body
  end

  should 'not display location fields when editing a profile' do
    Environment.any_instance.stubs(:custom_person_fields).returns({ 'location' => { 'active' => 'true' } })
    get informations_profile_editor_index_path(profile.identifier)

    !assert_tag 'input', attributes: { id: 'profile_data_state' }
    !assert_tag 'input', attributes: { id: 'profile_data_city' }
  end

  should 'update profile from remote form' do
    assert_nil profile.nickname
    post remote_edit_profile_editor_index_path(profile.identifier), params: { :profile_data => { :nickname => 'My Nickname' }, :field => 'nickname', :type => 'text', :format => 'js'}

    profile.reload
    assert profile.nickname, 'My Nickname'
  end

  should 'update profile from remote form and response in js format' do
    post remote_edit_profile_editor_index_path(profile.identifier), params: { :profile_data => { :nickname => 'My Nickname' }, :field => 'nickname', :type => 'text', :format => 'js'}

    assert_equal 'text/javascript', @response.content_type
    assert_match /profile_data_nickname/, @response.body
    assert_match /edit-in-place-container/, @response.body
    assert_match /My Nickname/, @response.body
  end

  should 'update profile image from remote form' do
    post remote_edit_profile_editor_index_path(profile.identifier), params: { :profile_data => { :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')}}, :format => 'js'}

    assert_match /profile_data_image_builder_uploaded_data/, @response.body
  end

  should 'return error message if update profile from remote form fails' do
    post remote_edit_profile_editor_index_path(profile.identifier), params: { :profile_data => { :name => '' }, :field => 'name', :type => 'text', :format => 'js'}

    assert_match /Sorry, name can't be blank/, @response.body
  end
end
