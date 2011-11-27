require File.dirname(__FILE__) + '/../test_helper'

class EnvironmentTest < ActiveSupport::TestCase
  fixtures :environments

  def test_exists_default_and_it_is_unique
    Environment.delete_all
    vc = Environment.new(:name => 'Test Community')
    vc.is_default = true
    assert vc.save

    vc2 = Environment.new(:name => 'Another Test Community')
    vc2.is_default = true
    assert !vc2.valid?
    assert vc2.errors.invalid?(:is_default)

    assert_equal vc, Environment.default
  end

  def test_acts_as_configurable
    vc = Environment.new(:name => 'Testing Environment')
    assert_kind_of Hash, vc.settings
    vc.settings[:some_setting] = 1
    assert vc.save
    assert_equal 1, vc.settings[:some_setting]
  end

  def test_available_features
    assert_kind_of Hash, Environment.available_features
  end

  def test_mock
    assert_equal ['feature1', 'feature2', 'feature3', 'xmpp_chat'], Environment.available_features.keys.sort
  end

  def test_features
    v = Environment.new
    v.enable('feature1')
    assert v.enabled?('feature1')
    v.disable('feature1')
    assert !v.enabled?('feature1')
  end

  def test_enabled_features
    v = Environment.new
    v.enabled_features = [ 'feature1', 'feature2' ]
    assert v.enabled?('feature1') && v.enabled?('feature2') && !v.enabled?('feature3')
  end

  def test_enabled_features_no_features_enabled
    v = Environment.new
    v.enabled_features = nil
    assert !v.enabled?('feature1') && !v.enabled?('feature2') && !v.enabled?('feature3')
  end

  def test_name_is_mandatory
    v = Environment.new
    v.valid?
    assert v.errors.invalid?(:name)
    v.name = 'blablabla'
    v.valid?
    assert !v.errors.invalid?(:name)
  end

  def test_terms_of_use
    v = Environment.new(:name => 'My test environment')
    assert_nil v.terms_of_use
    v.terms_of_use = 'To be part of this environment, you must accept the following terms: ...'
    assert v.save
    id = v.id
    assert_equal 'To be part of this environment, you must accept the following terms: ...', Environment.find(id).terms_of_use
  end

  should "terms of use not be an empty string" do
    v = Environment.new(:name => 'My test environment')
    assert_nil v.terms_of_use
    v.terms_of_use = ""
    assert v.save
    v.reload
    assert !v.has_terms_of_use?
  end

  def test_has_terms_of_use
    v = Environment.new
    assert !v.has_terms_of_use?
    v.terms_of_use = 'some terms of use'
    assert v.has_terms_of_use?
  end

  def test_terms_of_enterprise_use
    v = Environment.new(:name => 'My test environment')
    assert_nil v.terms_of_enterprise_use
    v.terms_of_enterprise_use = 'To be owner of an enterprise in this environment, you must accept the following terms: ...'
    assert v.save
    id = v.id
    assert_equal 'To be owner of an enterprise in this environment, you must accept the following terms: ...', Environment.find(id).terms_of_enterprise_use
  end

  def test_has_terms_of_enterprise_use
    v = Environment.new
    assert !v.has_terms_of_enterprise_use?
    v.terms_of_enterprise_use = 'some terms of enterprise use'
    assert v.has_terms_of_enterprise_use?
    v.terms_of_enterprise_use = ''
    assert !v.has_terms_of_enterprise_use?
  end

  def test_should_list_top_level_categories
    env = fast_create(Environment)
    cat1 = fast_create(Category, :name => 'first category', :environment_id => env.id)
    cat2 = fast_create(Category, :name => 'second category', :environment_id => env.id)
    subcat = fast_create(Category, :name => 'child category', :environment_id => env.id, :parent_id => cat2.id)

    cats = env.top_level_categories
    assert_equal 2, cats.size
    assert cats.include?(cat1)
    assert cats.include?(cat2)
    assert !cats.include?(subcat)
  end

  def test_should_list_all_categories
    env = fast_create(Environment)
    cat1 = fast_create(Category, :name => 'first category', :environment_id => env.id)
    cat2 = fast_create(Category, :name => 'second category', :environment_id => env.id)
    subcat = fast_create(Category, :name => 'child category', :environment_id => env.id, :parent_id => cat2.id)

    cats = env.categories
    assert_equal 3, cats.size
    assert cats.include?(cat1)
    assert cats.include?(cat2)
    assert cats.include?(subcat)
  end

  def test_should_list_all_product_categories
    env = fast_create(Environment)
    Category.create!(:name => 'first category', :environment_id => env.id)
    cat = Category.create!(:name => 'second category', :environment_id => env.id)
    Category.create!(:name => 'child category', :environment_id => env.id, :parent_id => cat.id)
    cat1 = ProductCategory.create!(:name => 'first product category', :environment_id => env.id)
    cat2 = ProductCategory.create!(:name => 'second product category', :environment_id => env.id)
    subcat = ProductCategory.create!(:name => 'child product category', :environment_id => env.id, :parent_id => cat2.id)

    cats = env.product_categories
    assert_equal 3, cats.size
    assert cats.include?(cat1)
    assert cats.include?(cat2)
    assert cats.include?(subcat)
  end

  should 'list displayable categories' do
    env = fast_create(Environment)
    cat1 = env.categories.create(:name => 'category one', :display_color => 1)
    assert ! cat1.new_record?

    # subcategories should be ignored
    subcat1 = env.categories.create(:name => 'subcategory one', :parent_id => cat1.id)
    assert ! subcat1.new_record?

    cat2 = env.categories.create(:name => 'category two')
    assert !cat2.new_record?

    assert_equal 1,  env.display_categories.size
    assert env.display_categories.include?(cat1)
    assert !env.display_categories.include?(cat2)
  end

  should 'have regions' do
    env = fast_create(Environment)
    assert_kind_of Array, env.regions
    assert_raise ActiveRecord::AssociationTypeMismatch do
      env.regions << 1
    end
    assert_nothing_raised do
      env.regions << Region.new
    end
  end

  should 'have a contact email' do
    env = Environment.new
    assert_nil env.contact_email

    env.contact_email = 'test'
    env.valid?
    assert env.errors.invalid?(:contact_email)

    env.contact_email = 'test@example.com'
    env.valid?
    assert !env.errors.invalid?(:contact_email)
  end

  should 'provide a default hostname' do
    env = fast_create(Environment)
    env.domains << Domain.create(:name => 'example.com', :is_default => true)
    assert_equal 'example.com', env.default_hostname
  end

  should 'default to localhost as hostname' do
    env = Environment.new
    assert_equal 'localhost', env.default_hostname
  end

  should 'add www when told to force www' do
    env = fast_create(Environment); env.force_www = true; env.save!

    env.domains << Domain.create(:name => 'example.com', :is_default => true)
    assert_equal 'www.example.com', env.default_hostname
  end

  should 'not add www when requesting domain for email address' do
    env = fast_create(Environment)
    env.domains << Domain.create(:name => 'example.com', :is_default => true)
    assert_equal 'example.com', env.default_hostname(true)
  end

  should 'use default domain when there is more than one' do
    env = fast_create(Environment)
    env.domains << Domain.create(:name => 'example.com', :is_default => false)
    env.domains << Domain.create(:name => 'default.com', :is_default => true)
    assert_equal 'default.com', env.default_hostname
  end

  should 'use first domain when there is no default' do
    env = fast_create(Environment)
    env.domains << Domain.create(:name => 'domain1.com', :is_default => false)
    env.domains << Domain.create(:name => 'domain2.com', :is_default => false)
    assert_equal 'domain1.com', env.default_hostname
  end

  should 'provide default top URL' do
    env = Environment.new
    env.expects(:default_hostname).returns('www.lalala.net')
    assert_equal 'http://www.lalala.net', env.top_url
  end

  should 'include port in default top URL for development environment' do
    env = Environment.new
    Noosfero.expects(:url_options).returns({ :port => 9999 }).at_least_once

    assert_equal 'http://localhost:9999', env.top_url
  end

  should 'provide an approval_method setting' do
    env = Environment.new

    # default value
    assert_equal :admin, env.organization_approval_method

    # valid values
    assert_nothing_raised do
      valid = %w[
        admin
        region
        none
      ].each do |item|
        env.organization_approval_method = item
        env.organization_approval_method = item.to_sym
      end
    end

    # do not allow other values
    assert_raise ArgumentError do
      env.organization_approval_method = :lalala
    end

  end

  should 'provide environment name in to_s' do
    env = Environment.new(:name => 'my name')
    assert_equal 'my name', env.to_s
  end

  should 'fallback to "?" when calling to_s with empty name' do
    env = Environment.new(:name => nil)
    assert_nil env.name
    assert_equal "?", env.to_s
  end

  should 'remove boxes and blocks when removing environment' do
    Environment.any_instance.stubs(:create_templates) # avoid creating templates, it's expensive
    env = Environment.create!(:name => 'test environment')

    env_boxes = env.boxes.size
    env_blocks = env.blocks.size
    assert env_boxes > 0
    assert env_blocks > 0

    boxes = Box.count
    blocks = Block.count

    env.destroy

    assert_equal boxes - env_boxes, Box.count
    assert_equal blocks - env_blocks, Block.count
  end

  should 'destroy templates' do
    env = fast_create(Environment)
    templates = [mock, mock, mock, mock]
    templates.each do |item|
      item.expects(:destroy)
    end

    env.stubs(:person_template).returns(templates[0])
    env.stubs(:community_template).returns(templates[1])
    env.stubs(:enterprise_template).returns(templates[2])
    env.stubs(:inactive_enterprise_template).returns(templates[3])

    env.destroy
  end

  should 'have boxes and blocks upon creation' do
    Environment.any_instance.stubs(:create_templates) # avoid creating templates, it's expensive
    environment = Environment.create!(:name => 'a test environment')
    assert environment.boxes.size > 0
    assert environment.blocks.size > 0
  end

  should 'have at least one MainBlock upon creation' do
    Environment.any_instance.stubs(:create_templates) # avoid creating templates, it's expensive
    environment = Environment.create!(:name => 'a test environment')
    assert(environment.blocks.any? { |block| block.kind_of? MainBlock })
  end

  should 'provide recent_documents' do
    environment = fast_create(Environment)

    p1 = fast_create(Profile, :environment_id => environment.id)
    p2 = fast_create(Profile, :environment_id => environment.id)

    # clear the articles
    Article.destroy_all

    # p1 creates one article
    doc1 = fast_create(Article, :profile_id => p1.id)

    # p2 creates two articles
    doc2 = fast_create(Article, :profile_id => p2.id)
    doc3 = fast_create(Article, :profile_id => p2.id)

    # p1 creates another article
    doc4 = fast_create(Article, :profile_id => p1.id)

    all_recent = environment.recent_documents
    [doc1,doc2,doc3,doc4].each do |item|
      assert_includes all_recent, item
    end

    last_three = environment.recent_documents(3)
    [doc2, doc3, doc4].each do |item|
      assert_includes last_three, item
    end
    assert_not_includes last_three, doc1

  end

  should 'have a description attribute' do
    env = Environment.new

    env.description = 'my fine environment'
    assert_equal 'my fine environment', env.description
  end

  should 'have admin role' do
    Role.expects(:find_by_key_and_environment_id).with('environment_administrator', Environment.default.id).returns(Role.new)
    assert_kind_of Role, Environment::Roles.admin(Environment.default.id)
  end

  should 'be able to add admins easily' do
    env = Environment.default
    user = create_user('testuser').person
    env.add_admin(user)

    assert_includes Environment.default.admins, user
  end

  should 'be able to remove admins easily' do
    env = Environment.default
    user = create_user('testuser').person
    env.affiliate(user, Environment::Roles.admin(env.id))
    assert_includes Environment.default.admins, user

    env.remove_admin(user)
    assert_not_includes Environment.default.admins, user
  end

  should 'have products through enterprises' do
    product_category = fast_create(ProductCategory, :name => 'Products', :environment_id => Environment.default.id)
    env = Environment.default
    e1 = fast_create(Enterprise)
    p1 = e1.products.create!(:name => 'test_prod1', :product_category => product_category)

    assert_includes env.products, p1
  end

  should 'collect the highlighted products with image through enterprises' do
    env = Environment.default
    e1 = fast_create(Enterprise)
    category = fast_create(ProductCategory)
    p1 = e1.products.create!(:name => 'test_prod1', :product_category_id => category.id)
    products = []
    3.times {|n|
      products.push(Product.create!(:name => "product #{n}", :enterprise_id => e1.id,
        :product_category_id => category.id, :highlighted => true,
        :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') }
      ))
    }
    Product.create!(:name => "product 4", :enterprise_id => e1.id, :product_category_id => category.id, :highlighted => true)
    Product.create!(:name => "product 5", :enterprise_id => e1.id, :product_category_id => category.id, :image_builder => {
        :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')
      })
    assert_equal products, env.highlighted_products_with_image
  end

  should 'not have person through communities' do
    env = Environment.default
    com = fast_create(Community)
    person = fast_create(Person)
    assert_includes env.communities, com
    assert_not_includes env.communities, person
  end

  should 'not have person through enterprises' do
    env = Environment.default
    ent = fast_create(Enterprise)
    person = fast_create(Person)
    assert_includes env.enterprises, ent
    assert_not_includes env.enterprises, person
  end

  should 'not have enterprises through people' do
    env = Environment.default
    person = fast_create(Person)
    ent = fast_create(Enterprise)
    assert_includes env.people, person
    assert_not_includes env.people, ent
  end

  should 'have a message_for_disabled_enterprise attribute' do
    env = Environment.new
    env.message_for_disabled_enterprise = 'this enterprise was disabled'
    assert_equal 'this enterprise was disabled', env.message_for_disabled_enterprise
  end

  should 'find by contents from articles' do
    environment = fast_create(Environment)
    assert_nothing_raised do
      environment.articles.find_by_contents('')
    end
  end

  should 'provide custom header' do
    assert_equal 'my header', Environment.new(:custom_header => 'my header').custom_header
  end

  should 'provide custom footer' do
    assert_equal 'my footer', Environment.new(:custom_footer => "my footer").custom_footer
  end

  should 'provide theme' do
    assert_equal 'my-custom-theme', Environment.new(:theme => 'my-custom-theme').theme
  end

  should 'give default theme' do
    assert_equal 'default', Environment.new.theme
  end

  should 'have a list of themes' do
    env = Environment.default

    t1 = 'theme_1'
    t2 = 'theme_2'

    Theme.expects(:system_themes).returns([Theme.new(t1), Theme.new(t2)])
    env.themes = [t1, t2]
    env.save!
    assert_equal  [t1, t2], Environment.default.themes.map(&:id)
  end

  should 'set themes to environment' do
    env = Environment.default

    env.themes = ['new-theme']
    env.save
    assert_equal  ['new-theme'], Environment.default.settings[:themes]
  end

  should 'return only themes included on system_themes' do
    Theme.expects(:system_themes).returns([Theme.new('new-theme')])
    env = Environment.default

    env.themes = ['new-theme', 'other-theme']
    env.save
    assert_equal  ['new-theme'], Environment.default.themes.map(&:id)
  end

  should 'add new themes to environment' do
    Theme.expects(:system_themes).returns([Theme.new('new-theme'), Theme.new('other-theme')])
    env = Environment.default

    env.add_themes(['new-theme', 'other-theme'])
    env.save
    assert_equal ['new-theme', 'other-theme'], Environment.default.themes.map(&:id)
  end

  should 'create templates' do
    e = Environment.create!(:name => 'test_env')
    e.reload

    # the templates must be created
    assert_kind_of Enterprise, e.enterprise_template
    assert_kind_of Enterprise, e.inactive_enterprise_template
    assert_kind_of Community, e.community_template
    assert_kind_of Person, e.person_template

    # the templates must be private
    assert !e.enterprise_template.visible?
    assert !e.inactive_enterprise_template.visible?
    assert !e.community_template.visible?
    assert !e.person_template.visible?
  end

  should 'set templates' do
    e = fast_create(Environment)

    comm = fast_create(Community)
    e.community_template = comm
    assert_equal comm, e.community_template

    person = fast_create(Person)
    e.person_template = person
    assert_equal person, e.person_template

    enterprise = fast_create(Enterprise)
    e.enterprise_template = enterprise
    assert_equal enterprise, e.enterprise_template
  end

  should 'have a layout template' do
    e = Environment.new(:layout_template => 'mytemplate')
    assert_equal 'mytemplate', e.layout_template
  end

  should 'have a default layout template' do
    assert_equal 'default', Environment.new.layout_template
  end

  should 'return more than 10 enterprises by contents' do
    env = Environment.default
    Enterprise.destroy_all
    ('1'..'20').each do |n|
      Enterprise.create!(:name => 'test ' + n, :identifier => 'test_' + n)
    end

    assert_equal 20, env.enterprises.find_by_contents('test').total_entries
  end

  should 'set replace_enterprise_template_when_enable on environment' do
    e = Environment.new(:name => 'Enterprise test')
    e.replace_enterprise_template_when_enable = true
    e.save
    assert_equal true, e.replace_enterprise_template_when_enable
  end

  should 'not replace enterprise template when enable by default' do
    assert_equal false, Environment.new.replace_enterprise_template_when_enable
  end

  should 'set custom_person_fields with its dependecies' do
    env = Environment.new
    env.custom_person_fields = {'cell_phone' => {'required' => 'true', 'active' => '', 'signup' => ''}, 'comercial_phone'=>  {'required' => '', 'active' => 'true', 'signup' => '' }, 'description' => {'required' => '', 'active' => '', 'signup' => 'true'}}

    assert_equal({'cell_phone' => {'required' => 'true', 'active' => 'true', 'signup' => 'true'}, 'comercial_phone'=>  {'required' => '', 'active' => 'true', 'signup' => '' }, 'description' => {'required' => '', 'active' => 'true', 'signup' => 'true'}}, env.custom_person_fields)
  end

  should 'have no custom_person_fields by default' do
    assert_equal({}, Environment.new.custom_person_fields)
  end

  should 'not set in custom_person_fields if not in person.fields' do
    env = Environment.default
    Person.stubs(:fields).returns(['cell_phone', 'comercial_phone'])

    env.custom_person_fields = { 'birth_date' => {'required' => 'true', 'active' => 'true'}, 'cell_phone' => {'required' => 'true', 'active' => 'true'}}
    assert_equal({'cell_phone' => {'required' => 'true','signup' => 'true',  'active' => 'true'}}, env.custom_person_fields)
    assert ! env.custom_person_fields.keys.include?('birth_date')
  end

  should 'add schooling_status if custom_person_fields has schooling' do
    env = Environment.default
    Person.stubs(:fields).returns(['cell_phone', 'schooling'])

    env.custom_person_fields = { 'schooling' => {'required' => 'true', 'active' => 'true'}}
    assert_equal({'schooling' => {'required' => 'true', 'signup' => 'true', 'active' => 'true'}, 'schooling_status' => {'required' => 'true', 'signup' => 'true', 'active' => 'true'}}, env.custom_person_fields)
    assert ! env.custom_person_fields.keys.include?('birth_date')
  end

  should 'return person_fields status' do
    env = Environment.default

    env.expects(:custom_person_fields).returns({ 'birth_date' => {'required' => 'true', 'active' => 'false'}}).at_least_once

    assert_equal true, env.custom_person_field('birth_date', 'required')
    assert_equal false, env.custom_person_field('birth_date', 'active')
  end

  should 'select active fields from person' do
    env = Environment.default
    env.expects(:custom_person_fields).returns({ 'birth_date' => {'required' => 'true', 'active' => 'true'}, 'cell_phone' => {'required' => 'true', 'active' => 'false'}}).at_least_once

    assert_equal ['birth_date'], env.active_person_fields
  end

  should 'select required fields from person' do
    env = Environment.default
    env.expects(:custom_person_fields).returns({ 'birth_date' => {'required' => 'true', 'active' => 'true'}, 'cell_phone' => {'required' => 'false', 'active' => 'true'}}).at_least_once

    assert_equal ['birth_date'], env.required_person_fields
  end

  should 'provide a default invitation message for friend' do
    env = Environment.default
    message = [
      'Hello <friend>,',
      "<user> is inviting you to participate on <environment>.",
      'To accept the invitation, please follow this link:',
      '<url>',
      "--\n<environment>",
    ].join("\n\n")

    assert_equal message, env.message_for_friend_invitation
  end

  should 'provide a default invitation message for member' do
    env = Environment.default
    message = env.message_for_member_invitation
    ['<friend>', '<user>', '<community>', '<environment>'].each do |item|
      assert_match(item, message)
    end
  end

  should 'set custom_enterprise_fields with its dependencies' do
    env = Environment.new
    env.custom_enterprise_fields = {'contact_person' => {'required' => 'true', 'active' => '', 'signup' => ''}, 'contact_email'=>  {'required' => '', 'active' => 'true', 'signup' => '' }, 'description' => {'required' => '', 'active' => '', 'signup' => 'true'}}

    assert_equal({'contact_person' => {'required' => 'true', 'active' => 'true', 'signup' => 'true'}, 'contact_email'=>  {'required' => '', 'active' => 'true', 'signup' => '' }, 'description' => {'required' => '', 'active' => 'true', 'signup' => 'true'}} , env.custom_enterprise_fields)
  end

  should 'have no custom_enterprise_fields by default' do
    assert_equal({}, Environment.new.custom_enterprise_fields)
  end

  should 'not set in custom_enterprise_fields if not in enterprise.fields' do
    env = Environment.default
    Enterprise.stubs(:fields).returns(['contact_person', 'comercial_phone'])

    env.custom_enterprise_fields = { 'contact_email' => {'required' => 'true', 'active' => 'true'}, 'contact_person' => {'required' => 'true', 'active' => 'true'}}
    assert_equal({'contact_person' => {'required' => 'true', 'signup' => 'true', 'active' => 'true'}}, env.custom_enterprise_fields)
    assert ! env.custom_enterprise_fields.keys.include?('contact_email')
  end

  should 'return enteprise_fields status' do
    env = Environment.default

    env.expects(:custom_enterprise_fields).returns({ 'contact_email' => {'required' => 'true', 'active' => 'false'}}).at_least_once

    assert_equal true, env.custom_enterprise_field('contact_email', 'required')
    assert_equal false, env.custom_enterprise_field('contact_email', 'active')
  end

  should 'select active fields from enterprise' do
    env = Environment.default
    env.expects(:custom_enterprise_fields).returns({ 'contact_email' => {'required' => 'true', 'active' => 'true'}, 'contact_person' => {'required' => 'true', 'active' => 'false'}}).at_least_once

    assert_equal ['contact_email'], env.active_enterprise_fields
  end

  should 'select required fields from enterprise' do
    env = Environment.default
    env.expects(:custom_enterprise_fields).returns({ 'contact_email' => {'required' => 'true', 'active' => 'true'}, 'contact_person' => {'required' => 'false', 'active' => 'true'}}).at_least_once

    assert_equal ['contact_email'], env.required_enterprise_fields
  end

  should 'set custom_community_fields with its dependencies' do
    env = Environment.new
    env.custom_community_fields = {'contact_person' => {'required' => 'true', 'active' => '', 'signup' => ''}, 'contact_email'=>  {'required' => '', 'active' => 'true', 'signup' => '' }, 'description' => {'required' => '', 'active' => '', 'signup' => 'true'}}

    assert_equal({'contact_person' => {'required' => 'true', 'active' => 'true', 'signup' => 'true'}, 'contact_email'=>  {'required' => '', 'active' => 'true', 'signup' => '' }, 'description' => {'required' => '', 'active' => 'true', 'signup' => 'true'}} , env.custom_community_fields)
  end

  should 'have no custom_community_fields by default' do
    assert_equal({}, Environment.new.custom_community_fields)
  end

  should 'not set in custom_community_fields if not in community.fields' do
    env = Environment.default
    Community.stubs(:fields).returns(['contact_person', 'comercial_phone'])

    env.custom_community_fields = { 'contact_email' => {'required' => 'true', 'active' => 'true'}, 'contact_person' => {'required' => 'true', 'active' => 'true'}}
    assert_equal({'contact_person' => {'required' => 'true', 'signup' => 'true', 'active' => 'true'}}, env.custom_community_fields)
    assert ! env.custom_community_fields.keys.include?('contact_email')
  end

  should 'return community_fields status' do
    env = Environment.default

    env.expects(:custom_community_fields).returns({ 'contact_email' => {'required' => 'true', 'active' => 'false'}}).at_least_once

    assert_equal true, env.custom_community_field('contact_email', 'required')
    assert_equal false, env.custom_community_field('contact_email', 'active')
  end

  should 'select active fields from community' do
    env = Environment.default
    env.expects(:custom_community_fields).returns({ 'contact_email' => {'required' => 'true', 'active' => 'true'}, 'contact_person' => {'required' => 'true', 'active' => 'false'}}).at_least_once

    assert_equal ['contact_email'], env.active_community_fields
  end

  should 'select required fields from community' do
    env = Environment.default
    env.expects(:custom_community_fields).returns({ 'contact_email' => {'required' => 'true', 'active' => 'true'}, 'contact_person' => {'required' => 'false', 'active' => 'true'}}).at_least_once

    assert_equal ['contact_email'], env.required_community_fields
  end

  should 'has tasks' do
    e = Environment.default
    assert_nothing_raised do
      e.tasks
    end
  end

  should 'have a portal community' do
    e = Environment.default
    c = fast_create(Community)

    e.portal_community = c; e.save!
    e.reload

    assert_equal c, e.portal_community
  end

  should 'unset the portal community' do
    e = Environment.default
    c = fast_create(Community)

    e.portal_community = c; e.save!
    e.reload
    assert_equal c, e.portal_community
    e.unset_portal_community!
    e.reload
    assert_nil e.portal_community 
    assert_equal [], e.portal_folders
    assert_equal 0, e.news_amount_by_folder
    assert_equal false, e.enabled?('use_portal_community')
  end

  should 'have a set of portal folders' do
    e = Environment.default

    c = e.portal_community = fast_create(Community)
    news_folder = fast_create(Folder, :name => 'news folder', :profile_id => c.id)

    e.portal_folders = [news_folder]
    e.save!; e.reload

    assert_equal [news_folder], e.portal_folders
  end

  should 'return empty array when no portal folders' do
   e = Environment.default

   assert_equal [], e.portal_folders
  end

  should 'remove all portal folders' do
    e = Environment.default

    e.portal_folders = nil
    e.save!; e.reload

    assert_equal [], e.portal_folders
  end

  should 'not crash when a portal folder is removed' do
    e = Environment.default

    c = e.portal_community = fast_create(Community)
    news_folder = fast_create(Folder, :name => 'news folder', :profile_id => c.id)

    e.portal_folders = [news_folder]
    e.save!; e.reload

    news_folder.destroy

    assert_not_includes e.portal_folders, nil
  end

  should 'have roles with names independent of other environments' do
    e1 = fast_create(Environment)
    role1 = Role.create!(:name => 'test_role', :environment => e1)
    e2 = fast_create(Environment)
    role2 = Role.new(:name => 'test_role', :environment => e2)

    assert role2.valid?
  end

  should 'have roles with keys independent of other environments' do
    e1 = fast_create(Environment)
    role1 = Role.create!(:name => 'test_role', :environment => e1, :key => 'a_member')
    e2 = fast_create(Environment)
    role2 = Role.new(:name => 'test_role', :environment => e2, :key => 'a_member')

    assert role2.valid?
  end

  should 'have a help_message_to_add_enterprise attribute' do
    env = Environment.new

    assert_equal env.help_message_to_add_enterprise, ''

    env.help_message_to_add_enterprise = 'help message'
    assert_equal 'help message', env.help_message_to_add_enterprise
  end

  should 'have a tip_message_enterprise_activation_question attribute' do
    env = Environment.new

    assert_equal env.tip_message_enterprise_activation_question, ''

    env.tip_message_enterprise_activation_question = 'tip message'
    assert_equal 'tip message', env.tip_message_enterprise_activation_question
  end

  should 'have amount of news on portal folders' do
    e = Environment.default

    assert_respond_to e, :news_amount_by_folder

    e.news_amount_by_folder = 2
    e.save!; e.reload

    assert_equal 2, e.news_amount_by_folder
  end

  should 'have default amount of news on portal folders' do
    e = Environment.default

    assert_respond_to e, :news_amount_by_folder

    assert_equal 4, e.news_amount_by_folder
  end

  should 'list tags with their counts' do
    person = fast_create(Person)
    person.articles.create!(:name => 'article 1', :tag_list => 'first-tag')
    person.articles.create!(:name => 'article 2', :tag_list => 'first-tag, second-tag')
    person.articles.create!(:name => 'article 3', :tag_list => 'first-tag, second-tag, third-tag')

    assert_equal({ 'first-tag' => 3, 'second-tag' => 2, 'third-tag' => 1 }, Environment.default.tag_counts)
  end

  should 'not list tags count from other environment' do
    e = fast_create(Environment)
    user = create_user('testinguser', :environment => e).person
    user.articles.build(:name => 'article 1', :tag_list => 'first-tag').save!

    assert_equal({}, Environment.default.tag_counts)
  end

  should 'have a list of local documentation links' do
    e = fast_create(Environment)
    e.local_docs = [['/doccommunity/link1', 'Link 1'], ['/doccommunity/link2', 'Link 2']]
    e.save!

    e = Environment.find(e.id)
    assert_equal [['/doccommunity/link1', 'Link 1'], ['/doccommunity/link2', 'Link 2']], e.local_docs
  end

  should 'have an empty list of local docs by default' do
    assert_equal [], Environment.new.local_docs
  end

  should 'provide right invitation mail template for friends' do
    env = Environment.default
    person = Person.new

    assert_equal env.message_for_friend_invitation, env.invitation_mail_template(person)
  end

  should 'provide right invitation mail template for members' do
    env = Environment.default
    community = Community.new

    assert_equal env.message_for_member_invitation, env.invitation_mail_template(community)
  end

  should 'translate friend invitation message' do
    InviteFriend.expects(:_).returns('').at_least_once
    Environment.new.message_for_friend_invitation
  end
  should 'translate member invitation message' do
    InviteMember.expects(:_).returns('').at_least_once
    Environment.new.message_for_member_invitation
  end

  should 'filter fields with white_list filter' do
    environment = Environment.new
    environment.message_for_disabled_enterprise = "<h1> Disabled Enterprise </h1>"
    environment.valid?

    assert_equal "<h1> Disabled Enterprise </h1>", environment.message_for_disabled_enterprise
  end

  should 'escape malformed html tags' do
    environment = Environment.new
    environment.message_for_disabled_enterprise = "<h1> Disabled Enterprise /h1>"
    environment.valid?

    assert_no_match /[<>]/, environment.message_for_disabled_enterprise
  end

  should 'not sanitize html comments' do
    environment = Environment.new
    environment.message_for_disabled_enterprise = '<p><!-- <asdf> << aasdfa >>> --> <h1> Wellformed html code </h1>'
    environment.valid?

    assert_match  /<!-- .* --> <h1> Wellformed html code <\/h1>/, environment.message_for_disabled_enterprise
  end

  should "not crash when set nil as terms of use" do
    v = Environment.new(:name => 'My test environment')
    v.terms_of_use = nil
    assert v.save!
  end

  should "terms of use not be an blank string" do
    v = Environment.new(:name => 'My test environment')
    v.terms_of_use = "   "
    assert v.save!
    assert !v.has_terms_of_use?
  end

  should 'have currency unit attribute' do
    env = Environment.new
    assert_equal env.currency_unit, '$'

    env.currency_unit = 'R$'
    assert_equal 'R$', env.currency_unit
  end

  should 'have currency separator attribute' do
    env = Environment.new
    assert_equal env.currency_separator, '.'

    env.currency_separator = ','
    assert_equal ',', env.currency_separator
  end

  should 'have currency delimiter attribute' do
    env = Environment.new
    assert_equal env.currency_delimiter, ','

    env.currency_delimiter = '.'
    assert_equal '.', env.currency_delimiter
  end

  should 'set a new theme' do
    env = fast_create(Environment)
    env.theme = 'another'
    env.save! && env.reload
    assert_equal 'another', env.theme
  end

  should 'not accept environment without theme' do
    env = fast_create(Environment)
    env.theme = nil
    assert_raise ActiveRecord::RecordInvalid do
      env.save!
    end
  end

  should 'has many users' do
    user_from_other_environment = create_user('one user from other env', :environment => Environment.default)
    env = fast_create(Environment)
    user_from_this_environment1 = create_user('one user', :environment => env)
    user_from_this_environment2 = create_user('another user', :environment => env)
    user_from_this_environment3 = create_user('some other user', :environment => env)
    assert_includes env.users, user_from_this_environment1
    assert_includes env.users, user_from_this_environment2
    assert_includes env.users, user_from_this_environment3
    assert_not_includes env.users, user_from_other_environment
  end

  should 'provide cache time for home page' do
    env = Environment.new
    assert env.respond_to?(:home_cache_in_minutes)
  end

  should 'store cache time for home page' do
    env = Environment.new(:home_cache_in_minutes => 99)
    assert_equal 99, env.home_cache_in_minutes
  end

  should 'retrieve cache time for home page' do
    env = fast_create(Environment)
    env.home_cache_in_minutes = 33
    env.save!

    assert_equal 33, Environment.find(env.id).home_cache_in_minutes
  end

  should 'cache home page for 5 minutes by default' do
    env = Environment.new
    assert_equal 5, env.home_cache_in_minutes
  end

  should 'provide cache time for general content' do
    env = Environment.new
    assert env.respond_to?(:general_cache_in_minutes)
  end

  should 'store cache time for general content' do
    env = Environment.new(:general_cache_in_minutes => 99)
    assert_equal 99, env.general_cache_in_minutes
  end

  should 'retrieve cache time for general content' do
    env = fast_create(Environment)
    env.general_cache_in_minutes = 33
    env.save!

    assert_equal 33, Environment.find(env.id).general_cache_in_minutes
  end

  should 'cache general content for 15 minutes by default' do
    env = Environment.new
    assert_equal 15, env.general_cache_in_minutes
  end

  should 'provide cache time for profile content' do
    env = Environment.new
    assert env.respond_to?(:profile_cache_in_minutes)
  end

  should 'store cache time for profile content' do
    env = Environment.new(:profile_cache_in_minutes => 99)
    assert_equal 99, env.profile_cache_in_minutes
  end

  should 'retrieve cache time for profile content' do
    env = fast_create(Environment)
    env.profile_cache_in_minutes = 33
    env.save!

    assert_equal 33, Environment.find(env.id).profile_cache_in_minutes
  end

  should 'cache profile content for 15 minutes by default' do
    env = Environment.new
    assert_equal 15, env.profile_cache_in_minutes
  end

  should 'have a list of trusted sites by default' do
    assert_equal ['developer.myspace.com', 'itheora.org', 'maps.google.com', 'platform.twitter.com', 'player.vimeo.com', 'stream.softwarelivre.org', 'tv.softwarelivre.org', 'www.facebook.com', 'www.flickr.com', 'www.gmodules.com', 'www.youtube.com', 'a.yimg.com', 'b.yimg.com', 'c.yimg.com', 'd.yimg.com', 'e.yimg.com', 'f.yimg.com', 'g.yimg.com', 'h.yimg.com', 'i.yimg.com', 'j.yimg.com', 'k.yimg.com', 'l.yimg.com', 'm.yimg.com', 'n.yimg.com', 'o.yimg.com', 'p.yimg.com', 'q.yimg.com', 'r.yimg.com', 's.yimg.com', 't.yimg.com', 'u.yimg.com', 'v.yimg.com', 'w.yimg.com', 'x.yimg.com', 'y.yimg.com', 'z.yimg.com'], Environment.new.trusted_sites_for_iframe
  end

  should 'have a list of trusted sites' do
    e = Environment.default
    e.trusted_sites_for_iframe = ['trusted.site.org']
    e.save!

    assert_equal ['trusted.site.org'], Environment.default.trusted_sites_for_iframe
  end

  should 'provide list of galleries' do
    env = Environment.new
    portal = Community.new
    env.stubs(:portal_community).returns(portal)
    list = []
    portal.expects(:image_galleries).returns(list)

    assert_same list, env.image_galleries
  end

  should 'profile empty list of image galleries when there is no portal community' do
    p = Environment.new
    p.stubs(:portal_community).returns(nil)
    assert_equal [], p.image_galleries
  end

  should 'get enabled features' do
    env = Environment.new
    env.enable('feature1')
    env.enable('feature2')
    env.disable('feature3')

    assert_includes env.enabled_features.keys, 'feature1'
    assert_includes env.enabled_features.keys, 'feature2'
    assert_not_includes env.enabled_features.keys, 'feature3'
  end

  should 'has a list of units ordered by position' do
    litre = Unit.create!(:singular => 'Litre', :plural => 'Litres', :environment => Environment.default)
    meter = Unit.create!(:singular => 'Meter', :plural => 'Meters', :environment => Environment.default)
    kilo  = Unit.create!(:singular => 'Kilo',  :plural => 'Kilo',   :environment => Environment.default)
    litre.move_to_bottom
    assert_equal ["Meter", "Kilo", "Litre"], Environment.default.units.map(&:singular)
  end

  should 'not include port in default hostname' do
    env = Environment.new
    Noosfero.stubs(:url_options).returns({ :port => 9999 })
    assert_no_match /9999/, env.default_hostname
  end

  should 'identify scripts with regex' do
    scripts_extensions = %w[php php1 php4 phps cgi shtm phtm shtml phtml pl py rb]
    scripts_extensions.each do |extension|
      assert_not_nil extension =~ Environment::IDENTIFY_SCRIPTS
    end
  end

  should 'filter file as script only if it has the extension as a script extension' do
    name = 'file_php_testing'
    assert_equal name, Environment.verify_filename(name)

    name += '.php'
    assert_equal name+'.txt', Environment.verify_filename(name)

    name += '.bli'
    assert_equal name, Environment.verify_filename(name)
  end

  should 'verify filename and append .txt if script' do
    scripts_extensions = %w[php php1 php4 phps cgi shtm phtm shtml phtml pl py rb]
    name = 'uploaded_file'
    scripts_extensions.each do |extension|
      filename = name+'.'+extension
      assert_equal filename+'.txt', Environment.verify_filename(filename)
    end
  end

  should 'not conflict to save classes with namespace on sti' do
    class School; end;
    class Work; end;
    class School::Project < Article; end
    class Work::Project < Article; end

    title1 = "Sample Article1"
    title2 = "Sample Article2"
    profile = fast_create(Profile)

    p1 = School::Project.new(:name => title1, :profile => profile)
    p2 = Work::Project.new(:name => title2, :profile => profile)

    p1.save!
    p2.save!
  end

  should 'always store setting keys as symbol' do
    env = Environment.default
    env.settings['string_key'] = 'new value'
    env.save!; env.reload
    assert_nil env.settings['string_key']
    assert_equal env.settings[:string_key], 'new value'
  end

  should 'validate reports_lower_bound' do
    environment = Environment.new

    environment.reports_lower_bound = nil
    environment.valid?
    assert environment.errors.invalid?(:reports_lower_bound)

    environment.reports_lower_bound = -3
    environment.valid?
    assert environment.errors.invalid?(:reports_lower_bound)

    environment.reports_lower_bound = 1.5
    environment.valid?
    assert environment.errors.invalid?(:reports_lower_bound)

    environment.reports_lower_bound = 5
    environment.valid?
    assert !environment.errors.invalid?(:reports_lower_bound)
  end

  should 'be able to enable or disable a plugin' do
    environment = Environment.default
    plugin = 'Plugin'

    environment.enable_plugin(plugin)
    environment.reload
    assert_includes environment.enabled_plugins, plugin

    environment.disable_plugin(plugin)
    environment.reload
    assert_not_includes environment.enabled_plugins, plugin
  end

end
