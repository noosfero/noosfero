require_relative "../test_helper"

class EnvironmentTest < ActiveSupport::TestCase
  fixtures :environments

  def test_exists_default_and_it_is_unique
    Environment.delete_all
    vc = build(Environment, :name => 'Test Community')
    vc.is_default = true
    assert vc.save

    vc2 = build(Environment, :name => 'Another Test Community')
    vc2.is_default = true
    refute vc2.valid?
    assert vc2.errors[:is_default.to_s].present?

    assert_equal vc, Environment.default
  end

  def test_acts_as_configurable
    vc = build(Environment, :name => 'Testing Environment')
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
    v = fast_create(Environment)
    v.enable('feature1', false)
    assert v.enabled?('feature1')
    v.disable('feature1', false)
    refute v.enabled?('feature1')
  end

  def test_enabled_features
    v = fast_create(Environment)
    v.enable('feature1', false)
    v.enable('feature2', false)
    assert v.enabled?('feature1') && v.enabled?('feature2') && !v.enabled?('feature3')
  end

  def test_enabled_features_no_features_enabled
    v = fast_create(Environment)
    refute v.enabled?('feature1') && !v.enabled?('feature2') && !v.enabled?('feature3')
  end

  def test_default_enabled_features_are_enabled
    environment = Environment.create(:name => 'Testing')
    Environment::DEFAULT_FEATURES.each do |features|
      assert environment.enabled?(features)
    end
  end

  def test_name_is_mandatory
    v = Environment.new
    v.valid?
    assert v.errors[:name.to_s].present?
    v.name = 'blablabla'
    v.valid?
    refute v.errors[:name.to_s].present?
  end

  def test_terms_of_use
    v = fast_create(Environment, :name => 'My test environment')
    assert_nil v.terms_of_use
    v.terms_of_use = 'To be part of this environment, you must accept the following terms: ...'
    assert v.save
    id = v.id
    assert_equal 'To be part of this environment, you must accept the following terms: ...', Environment.find(id).terms_of_use
  end

  should "terms of use not be an empty string" do
    v = fast_create(Environment, :name => 'My test environment')
    assert_nil v.terms_of_use
    v.terms_of_use = ""
    assert v.save
    v.reload
    refute v.has_terms_of_use?
  end

  def test_has_terms_of_use
    v = Environment.new
    refute v.has_terms_of_use?
    v.terms_of_use = 'some terms of use'
    assert v.has_terms_of_use?
  end

  def test_terms_of_enterprise_use
    v = fast_create(Environment, :name => 'My test environment')
    assert_nil v.terms_of_enterprise_use
    v.terms_of_enterprise_use = 'To be owner of an enterprise in this environment, you must accept the following terms: ...'
    assert v.save
    id = v.id
    assert_equal 'To be owner of an enterprise in this environment, you must accept the following terms: ...', Environment.find(id).terms_of_enterprise_use
  end

  def test_has_terms_of_enterprise_use
    v = Environment.new
    refute v.has_terms_of_enterprise_use?
    v.terms_of_enterprise_use = 'some terms of enterprise use'
    assert v.has_terms_of_enterprise_use?
    v.terms_of_enterprise_use = ''
    refute v.has_terms_of_enterprise_use?
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
    refute cats.include?(subcat)
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
    create(Category, :name => 'first category', :environment_id => env.id)
    cat = create(Category, :name => 'second category', :environment_id => env.id)
    create(Category, :name => 'child category', :environment_id => env.id, :parent_id => cat.id)
    cat1 = create(ProductCategory, :name => 'first product category', :environment_id => env.id)
    cat2 = create(ProductCategory, :name => 'second product category', :environment_id => env.id)
    subcat = create(ProductCategory, :name => 'child product category', :environment_id => env.id, :parent_id => cat2.id)

    cats = env.product_categories
    assert_equal 3, cats.size
    assert cats.include?(cat1)
    assert cats.include?(cat2)
    assert cats.include?(subcat)
  end

  should 'list displayable categories' do
    env = fast_create(Environment)
    cat1 = create(Category, :environment => env, :name => 'category one', :display_color => 'ffa500')
    refute  cat1.new_record?

    # subcategories should be ignored
    subcat1 = create(Category, :environment => env, :name => 'subcategory one', :parent_id => cat1.id)
    refute  subcat1.new_record?

    cat2 = create(Category, :environment => env, :name => 'category two')
    refute cat2.new_record?

    assert_equal 1,  env.display_categories.size
    assert env.display_categories.include?(cat1)
    refute env.display_categories.include?(cat2)
  end

  should 'have regions' do
    env = fast_create(Environment)
    assert env.regions.empty?
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
    assert env.errors[:contact_email.to_s].present?

    env.contact_email = 'test@example.com'
    env.valid?
    refute env.errors[:contact_email.to_s].present?
  end

  should 'notify contact email' do
    env = Environment.new(:contact_email => 'foo@bar.com')
    env.stubs(:admins).returns([])
    assert_equal ['foo@bar.com'], env.notification_emails
  end

  should 'provide a default hostname' do
    env = fast_create(Environment)
    env.domains << create(Domain, :name => 'example.com', :is_default => true)
    assert_equal 'example.com', env.default_hostname
  end

  should 'default to localhost as hostname' do
    env = Environment.new
    assert_equal 'localhost', env.default_hostname
  end

  should 'add www when told to force www' do
    env = fast_create(Environment); env.force_www = true; env.save!

    env.domains << create(Domain, :name => 'example.com', :is_default => true)
    assert_equal 'www.example.com', env.default_hostname
  end

  should 'not add www when requesting domain for email address' do
    env = fast_create(Environment)
    env.domains << create(Domain, :name => 'example.com', :is_default => true)
    assert_equal 'example.com', env.default_hostname(true)
  end

  should 'use default domain when there is more than one' do
    env = fast_create(Environment)
    env.domains << create(Domain, :name => 'example.com', :is_default => false)
    env.domains << create(Domain, :name => 'default.com', :is_default => true)
    assert_equal 'default.com', env.default_hostname
  end

  should 'use first domain when there is no default' do
    env = fast_create(Environment)
    env.domains << create(Domain, :name => 'domain1.com', :is_default => false)
    env.domains << create(Domain, :name => 'domain2.com', :is_default => false)
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
    env = build(Environment, :name => 'my name')
    assert_equal 'my name', env.to_s
  end

  should 'fallback to "?" when calling to_s with empty name' do
    env = build(Environment, :name => nil)
    assert_nil env.name
    assert_equal "?", env.to_s
  end

  should 'remove boxes and blocks when removing environment' do
    Environment.any_instance.stubs(:create_templates) # avoid creating templates, it's expensive
    env = create(Environment, :name => 'test environment')

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

  should 'have boxes and blocks upon creation' do
    Environment.any_instance.stubs(:create_templates) # avoid creating templates, it's expensive
    environment = create(Environment, :name => 'a test environment')
    assert environment.boxes.size > 0
    assert environment.blocks.size > 0
  end

  should 'have at least one MainBlock upon creation' do
    Environment.any_instance.stubs(:create_templates) # avoid creating templates, it's expensive
    environment = create(Environment, :name => 'a test environment')
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
    Role.expects(:find_by).with(key: 'environment_administrator', environment_id: Environment.default.id).returns(Role.new)
    assert_kind_of Role, Environment::Roles.admin(Environment.default.id)
  end

  should 'create environment and profile default roles' do
    env = Environment.default
    assert_equal 'Environment', env.roles.find_by(key: 'environment_administrator').kind
    assert_equal 'Profile', env.roles.find_by(key: 'profile_admin').kind
    assert_equal 'Profile', env.roles.find_by(key: 'profile_member').kind
    assert_equal 'Profile', env.roles.find_by(key: 'profile_moderator').kind
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
    p1 = create(Product, :enterprise => e1, :name => 'test_prod1', :product_category_id => category.id)
    products = []
    3.times {|n|
      products.push(create(Product, :name => "product #{n}", :profile_id => e1.id,
        :product_category_id => category.id, :highlighted => true,
        :image_builder => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png') }
      ))
    }
    create(Product, :name => "product 4", :profile_id => e1.id, :product_category_id => category.id, :highlighted => true)
    create(Product, :name => "product 5", :profile_id => e1.id, :product_category_id => category.id, :image_builder => {
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

  should 'provide custom header' do
    assert_equal 'my header', build(Environment, :custom_header => 'my header').custom_header
  end

  should 'provide custom footer' do
    assert_equal 'my footer', build(Environment, :custom_footer => "my footer").custom_footer
  end

  should 'provide theme' do
    assert_equal 'my-custom-theme', build(Environment, :theme => 'my-custom-theme').theme
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
    e = create(Environment, :name => 'test_env')
    e.reload

    # the templates must be created
    assert_kind_of Enterprise, e.enterprise_default_template
    assert_kind_of Enterprise, e.inactive_enterprise_template
    assert_kind_of Community, e.community_default_template
    assert_kind_of Person, e.person_default_template

    # the templates must be private
    refute e.enterprise_default_template.visible?
    refute e.inactive_enterprise_template.visible?
    refute e.community_default_template.visible?
    refute e.person_default_template.visible?
  end

  should 'person_templates return all templates of person' do
    e = fast_create(Environment)

    p1= fast_create(Person, :is_template => true, :environment_id => e.id)
    p2 = fast_create(Person, :environment_id => e.id)
    p3 = fast_create(Person, :is_template => true, :environment_id => e.id)
    assert_equivalent [p1,p3], e.person_templates
  end

  should 'person_templates return an empty array if there is no templates of person' do
    e = fast_create(Environment)

    fast_create(Person, :environment_id => e.id)
    fast_create(Person, :environment_id => e.id)
    assert_equivalent [], e.person_templates
  end

  should 'person_default_template return the template defined as default' do
    e = fast_create(Environment)

    p1= fast_create(Person, :is_template => true, :environment_id => e.id)
    p2 = fast_create(Person, :environment_id => e.id)
    p3 = fast_create(Person, :is_template => true, :environment_id => e.id)

    e.settings[:person_template_id]= p3.id
    assert_equal p3, e.person_default_template
  end

  should 'person_default_template not return a person if its not a template' do
    e = fast_create(Environment)

    p1= fast_create(Person, :is_template => true, :environment_id => e.id)
    p2 = fast_create(Person, :environment_id => e.id)
    p3 = fast_create(Person, :is_template => true, :environment_id => e.id)

    e.settings[:person_template_id]= p2.id
    assert_nil e.person_default_template
  end

  should 'person_default_template= define a person model passed as paremeter as default template' do
    e = fast_create(Environment)

    p1= fast_create(Person, :is_template => true, :environment_id => e.id)
    p2 = fast_create(Person, :environment_id => e.id)
    p3 = fast_create(Person, :is_template => true, :environment_id => e.id)

    e.person_default_template= p3
    assert_equal p3, e.person_default_template
  end

  should 'person_default_template= define an id passed as paremeter as the default template' do
    e = fast_create(Environment)

    p1= fast_create(Person, :is_template => true, :environment_id => e.id)
    p2 = fast_create(Person, :environment_id => e.id)
    p3 = fast_create(Person, :is_template => true, :environment_id => e.id)

    e.person_default_template= p3.id
    assert_equal p3, e.person_default_template
  end

  should 'community_templates return all templates of community' do
    e = fast_create(Environment)

    c1= fast_create(Community, :is_template => true, :environment_id => e.id)
    c2 = fast_create(Community, :environment_id => e.id)
    c3 = fast_create(Community, :is_template => true, :environment_id => e.id)
    assert_equivalent [c1,c3], e.community_templates
  end

  should 'community_templates return an empty array if there is no templates of community' do
    e = fast_create(Environment)

    fast_create(Community, :environment_id => e.id)
    fast_create(Community, :environment_id => e.id)
    assert_equivalent [], e.community_templates
  end

  should 'community_default_template return the template defined as default' do
    e = fast_create(Environment)

    c1= fast_create(Community, :is_template => true, :environment_id => e.id)
    c2 = fast_create(Community, :environment_id => e.id)
    c3 = fast_create(Community, :is_template => true, :environment_id => e.id)

    e.settings[:community_template_id]= c3.id
    assert_equal c3, e.community_default_template
  end

  should 'community_default_template not return a community if its not a template' do
    e = fast_create(Environment)

    c1= fast_create(Community, :is_template => true, :environment_id => e.id)
    c2 = fast_create(Community, :environment_id => e.id)
    c3 = fast_create(Community, :is_template => true, :environment_id => e.id)

    e.settings[:community_template_id]= c2.id
    assert_nil e.community_default_template
  end

  should 'community_default_template= define a community model passed as paremeter as default template' do
    e = fast_create(Environment)

    c1= fast_create(Community, :is_template => true, :environment_id => e.id)
    c2 = fast_create(Community, :environment_id => e.id)
    c3 = fast_create(Community, :is_template => true, :environment_id => e.id)

    e.community_default_template= c3
    assert_equal c3, e.community_default_template
  end

  should 'community_default_template= define an id passed as paremeter as the default template' do
    e = fast_create(Environment)

    c1= fast_create(Community, :is_template => true, :environment_id => e.id)
    c2 = fast_create(Community, :environment_id => e.id)
    c3 = fast_create(Community, :is_template => true, :environment_id => e.id)

    e.community_default_template= c3.id
    assert_equal c3, e.community_default_template
  end

  should 'enterprise_templates return all templates of enterprise' do
    env = fast_create(Environment)

    e1= fast_create(Enterprise, :is_template => true, :environment_id => env.id)
    e2 = fast_create(Enterprise, :environment_id => env.id)
    e3 = fast_create(Enterprise, :is_template => true, :environment_id => env.id)
    assert_equivalent [e1,e3], env.enterprise_templates
  end

  should 'enterprise_templates return an empty array if there is no templates of enterprise' do
    env = fast_create(Environment)

    fast_create(Enterprise, :environment_id => env.id)
    fast_create(Enterprise, :environment_id => env.id)
    assert_equivalent [], env.enterprise_templates
  end

  should 'enterprise_default_template return the template defined as default' do
    env = fast_create(Environment)

    e1= fast_create(Enterprise, :is_template => true, :environment_id => env.id)
    e2 = fast_create(Enterprise, :environment_id => env.id)
    e3 = fast_create(Enterprise, :is_template => true, :environment_id => env.id)

    env.settings[:enterprise_template_id]= e3.id
    assert_equal e3, env.enterprise_default_template
  end

  should 'enterprise_default_template not return a enterprise if its not a template' do
    env = fast_create(Environment)

    e1= fast_create(Enterprise, :is_template => true, :environment_id => env.id)
    e2 = fast_create(Enterprise, :environment_id => env.id)
    e3 = fast_create(Enterprise, :is_template => true, :environment_id => env.id)

    env.settings[:enterprise_template_id]= e2.id
    assert_nil env.enterprise_default_template
  end

  should 'enterprise_default_template= define a enterprise model passed as paremeter as default template' do
    env = fast_create(Environment)

    e1= fast_create(Enterprise, :is_template => true, :environment_id => env.id)
    e2 = fast_create(Enterprise, :environment_id => env.id)
    e3 = fast_create(Enterprise, :is_template => true, :environment_id => env.id)

    env.enterprise_default_template= e3
    assert_equal e3, env.enterprise_default_template
  end

  should 'enterprise_default_template= define an id passed as paremeter as the default template' do
    env = fast_create(Environment)

    e1= fast_create(Enterprise, :is_template => true, :environment_id => env.id)
    e2 = fast_create(Enterprise, :environment_id => env.id)
    e3 = fast_create(Enterprise, :is_template => true, :environment_id => env.id)

    env.enterprise_default_template= e3.id
    assert_equal e3, env.enterprise_default_template
  end

  should 'is_default_template? method identify a person default template as default' do
    env = fast_create(Environment)

    p1 = fast_create(Person, :is_template => true, :environment_id => env.id)
    env.person_default_template= p1.id
    assert env.is_default_template?(p1)

    p2 = fast_create(Person, :is_template => true, :environment_id => env.id)
    env.person_default_template= p2.id
    refute env.is_default_template?(p1)
  end

  should 'is_default_template? method identify a community default template as default' do
    env = fast_create(Environment)

    c1 = fast_create(Community, :is_template => true, :environment_id => env.id)
    env.community_default_template= c1.id
    assert env.is_default_template?(c1)

    c2 = fast_create(Community, :is_template => true, :environment_id => env.id)
    env.community_default_template= c2.id
    refute env.is_default_template?(c1)
  end

  should 'is_default_template? method identify a enterprise default template as default' do
    env = fast_create(Environment)

    e1 = fast_create(Enterprise, :is_template => true, :environment_id => env.id)
    env.enterprise_default_template= e1.id
    assert env.is_default_template?(e1)

    e2 = fast_create(Enterprise, :is_template => true, :environment_id => env.id)
    env.enterprise_default_template= e2.id
    refute env.is_default_template?(e1)
  end

  should 'have a layout template' do
    e = build(Environment, :layout_template => 'mytemplate')
    assert_equal 'mytemplate', e.layout_template
  end

  should 'have a default layout template' do
    assert_equal 'default', Environment.new.layout_template
  end

  should 'set replace_enterprise_template_when_enable on environment' do
    e = fast_create(Environment, :name => 'Enterprise test')
    e.replace_enterprise_template_when_enable = true
    e.save
    assert_equal true, e.replace_enterprise_template_when_enable
  end

  should 'not replace enterprise template when enable by default' do
    assert_equal false, Environment.new.replace_enterprise_template_when_enable
  end

  should 'set custom_person_fields with its dependecies' do
    env = Environment.new
    data = {'cell_phone' => {'required' => 'true', 'active' => '', 'signup' => ''}, 'comercial_phone'=>  {'required' => '', 'active' => 'true', 'signup' => '' }, 'description' => {'required' => '', 'active' => '', 'signup' => 'true'}}
    env.custom_person_fields = data

    assert(env.custom_person_fields.merge(data) == env.custom_person_fields)
  end

  should 'not set in custom_person_fields if not in person.fields' do
    env = Environment.default
    Person.stubs(:fields).returns(['cell_phone', 'comercial_phone'])

    env.custom_person_fields = { 'birth_date' => {'required' => 'true', 'active' => 'true'}, 'cell_phone' => {'required' => 'true', 'active' => 'true'}}
    expected_hash = {'cell_phone' => {'required' => 'true', 'active' => 'true', 'signup' => 'true'}}
    assert(env.custom_person_fields.merge(expected_hash) == env.custom_person_fields)
    refute  env.custom_person_fields.keys.include?('birth_date')
  end

  should 'add schooling_status if custom_person_fields has schooling' do
    env = Environment.default
    Person.stubs(:fields).returns(['cell_phone', 'schooling'])

    env.custom_person_fields = { 'schooling' => {'required' => 'true', 'active' => 'true'}}
    expected_hash = {'schooling' => {'required' => 'true', 'active' => 'true', 'signup' => 'true'}, 'schooling_status' => {'required' => 'true', 'signup' => 'true', 'active' => 'true'}}
    assert(env.custom_person_fields.merge(expected_hash) == env.custom_person_fields)
    refute  env.custom_person_fields.keys.include?('birth_date')
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
    refute  env.custom_enterprise_fields.keys.include?('contact_email')
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
    refute  env.custom_community_fields.keys.include?('contact_email')
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
    role1 = create(Role, :name => 'test_role', :environment => e1)
    e2 = fast_create(Environment)
    role2 = build(Role, :name => 'test_role', :environment => e2)

    assert role2.valid?
  end

  should 'have roles with keys independent of other environments' do
    e1 = fast_create(Environment)
    role1 = create(Role, :name => 'test_role', :environment => e1, :key => 'a_member')
    e2 = fast_create(Environment)
    role2 = build(Role, :name => 'test_role', :environment => e2, :key => 'a_member')

    assert role2.valid?
  end

  should 'destroy roles when its environment is destroyed' do
    e1 = fast_create(Environment)
    role1 = Role.create!(:name => 'test_role', :environment => e1, :key => 'a_member')
    e2 = fast_create(Environment)
    role2 = Role.create!(:name => 'test_role', :environment => e2, :key => 'a_member')

    e2.destroy

    assert_nothing_raised {Role.find(role1.id)}
    assert_raise(ActiveRecord::RecordNotFound) {Role.find(role2.id)}
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

  should 'have amount of highlighted news' do
    e = Environment.default

    assert_respond_to e, :highlighted_news_amount

    assert_equal 2, e.highlighted_news_amount
    e.highlighted_news_amount = 4
    e.save!

    assert_equal 4, Environment.default.highlighted_news_amount
  end

  should 'have amount of portal news' do
    e = Environment.default

    assert_respond_to e, :portal_news_amount

    assert_equal 5, e.portal_news_amount
    e.portal_news_amount = 2
    e.save!

    assert_equal 2, Environment.default.portal_news_amount
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

  should 'not sanitize html comments' do
    environment = Environment.new
    environment.message_for_disabled_enterprise = '<p><!-- <asdf> << aasdfa >>> --> <h1> Wellformed html code </h1>'
    environment.valid?

    assert_match  /<p><!-- .* --> <\/p><h1> Wellformed html code <\/h1>/, environment.message_for_disabled_enterprise
  end

  should "not crash when set nil as terms of use" do
    v = fast_create(Environment, :name => 'My test environment')
    v.terms_of_use = nil
    assert v.save!
  end

  should "terms of use not be an blank string" do
    v = fast_create(Environment)
    v.terms_of_use = '   '
    refute v.has_terms_of_use?
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
    env = build(Environment, :home_cache_in_minutes => 99)
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
    env = build(Environment, :general_cache_in_minutes => 99)
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
    env = build(Environment, :profile_cache_in_minutes => 99)
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
    assert_equal [String], Environment.new.trusted_sites_for_iframe.map(&:class).uniq
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
    env = fast_create(Environment)
    env.enable('feature1', false)
    env.enable('feature2', false)
    env.disable('feature3', false)

    assert_includes env.enabled_features.keys, 'feature1'
    assert_includes env.enabled_features.keys, 'feature2'
    assert_not_includes env.enabled_features.keys, 'feature3'
  end

  should 'has a list of units ordered by position' do
    litre = create(Unit, :singular => 'Litre', :plural => 'Litres', :environment => Environment.default)
    meter = create(Unit, :singular => 'Meter', :plural => 'Meters', :environment => Environment.default)
    kilo  = create(Unit, :singular => 'Kilo',  :plural => 'Kilo',   :environment => Environment.default)
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

    p1 = build(School::Project, :name => title1, :profile => profile)
    p2 = build(Work::Project, :name => title2, :profile => profile)

    p1.save!
    p2.save!
  end

  should 'always store setting keys as symbol' do
    Environment.settings_items :string_key, type: String
    env = Environment.default
    env.string_key = 'new value'
    env.save!; env.reload
    assert_equal env.settings[:string_key], 'new value'
    assert_nil env.settings['string_key']
  end

  should 'validate reports_lower_bound' do
    environment = Environment.new

    environment.reports_lower_bound = nil
    environment.valid?
    assert environment.errors[:reports_lower_bound.to_s].present?

    environment.reports_lower_bound = -3
    environment.valid?
    assert environment.errors[:reports_lower_bound.to_s].present?

    environment.reports_lower_bound = 1.5
    environment.valid?
    assert environment.errors[:reports_lower_bound.to_s].present?

    environment.reports_lower_bound = 5
    environment.valid?
    refute environment.errors[:reports_lower_bound.to_s].present?
  end

  should 'be able to enable or disable a plugin with the class or class name' do
    class Plugin
    end
    environment = Environment.default

    environment.enable_plugin(Plugin)
    environment.reload
    assert environment.plugin_enabled?(Plugin.to_s)

    environment.disable_plugin(Plugin.to_s)
    environment.reload
    refute environment.plugin_enabled?(Plugin)
  end

  should 'activate on database all available plugins' do
    plugins_enable = ["Statistics", "Foo", "PeopleBlock"]
    Noosfero::Plugins.stubs(:available_plugin_names).returns(plugins_enable)
    env1 = Environment.create(:name => "Test")
    env2 = Environment.create(:name => "Test 2")

    env1.enable_all_plugins
    env2.enable_all_plugins

    plugins = ["PeopleBlockPlugin", "StatisticsPlugin", "FooPlugin"]
    plugins.each do |plugin|
      assert env1.enabled_plugins.include?(plugin)
      assert env2.enabled_plugins.include?(plugin)
    end
  end

  should 'dont activate plugins that are not available' do
    env1 = Environment.create(:name => "Test")
    env2 = Environment.create(:name => "Test 2")

    env1.enable_all_plugins
    env2.enable_all_plugins

    plugins = ["SomePlugin", "OtherPlugin", "ThirdPlugin"]
    plugins.each do |plugin|
      assert_equal false, env1.enabled_plugins.include?(plugin)
      assert_equal false, env2.enabled_plugins.include?(plugin)
    end
  end

  should 'have production costs' do
    assert_respond_to Environment.default, :production_costs
  end

  should 'be able to have many licenses' do
    environment = Environment.default
    another_environment = fast_create(Environment)
    l1 = fast_create(License, :environment_id => environment.id)
    l2 = fast_create(License, :environment_id => environment.id)
    l3 = fast_create(License, :environment_id => another_environment)

    environment.reload

    assert_includes environment.licenses, l1
    assert_includes environment.licenses, l2
    assert_not_includes environment.licenses, l3
  end

  should 'return a Hash on login redirection options' do
    assert_kind_of Hash, Environment.login_redirection_options
  end

  should 'respond to redirection after login' do
    assert_respond_to Environment.new, :redirection_after_login
  end

  should 'allow only environment login redirection options' do
    environment = fast_create(Environment)
    environment.redirection_after_login = 'invalid_option'
    environment.save
    assert environment.errors[:redirection_after_login.to_s].present?

    Environment.login_redirection_options.keys.each do |redirection|
      environment.redirection_after_login = redirection
      environment.save
      refute environment.errors[:redirection_after_login.to_s].present?
    end
  end

  should 'return a Hash on signup redirection options' do
    assert_kind_of Hash, Environment.signup_redirection_options
  end

  should 'respond to redirection after signup' do
    assert_respond_to Environment.new, :redirection_after_signup
  end

  should 'allow only environment signup redirection options' do
    environment = fast_create(Environment)
    environment.redirection_after_signup = 'invalid_option'
    environment.save
    assert environment.errors[:redirection_after_signup.to_s].present?

    Environment.signup_redirection_options.keys.each do |redirection|
      environment.redirection_after_signup = redirection
      environment.save
      refute environment.errors[:redirection_after_signup.to_s].present?
    end
  end

  should 'respond to signup_welcome_text' do
    assert_respond_to Environment.new, :signup_welcome_text
  end

  should 'store welcome text in a hash serialized' do
    environment = Environment.default

    environment.signup_welcome_text = {
      :subject => 'Welcome to the environment',
      :body => 'Thanks for signing up!',
    }
    environment.save
    environment.reload

    assert_kind_of Hash, environment.signup_welcome_text
    assert_equal ['Welcome to the environment', 'Thanks for signing up!'], [environment.signup_welcome_text[:subject], environment.signup_welcome_text[:body]]
  end

  should 'not consider signup welcome text if not defined' do
    env = Environment.default
    refute env.has_signup_welcome_text?
  end

  should 'not consider signup welcome text if nil' do
    env = Environment.default

    env.signup_welcome_text = nil
    refute env.has_signup_welcome_text?
  end

  should 'not consider signup welcome text if body is nil' do
    env = Environment.default

    env.signup_welcome_text = {
      :subject => 'Welcome to the environment',
    }
    refute env.has_signup_welcome_text?
  end

  should 'consider signup welcome text if subject is nil but body is defined' do
    env = Environment.default

    env.signup_welcome_text = {
      :body => 'Thanks for signing up!',
    }
    assert env.has_signup_welcome_text?
  end

  should 'consider signup welcome text if subject and body are defined' do
    env = Environment.default

    env.signup_welcome_text = {
      :subject => 'Welcome to the environment',
      :body => 'Thanks for signing up!',
    }
    assert env.has_signup_welcome_text?
  end

  should 'store welcome text subject' do
    environment = Environment.default

    environment.signup_welcome_text_subject = 'Welcome to the environment'
    environment.save
    environment.reload

    assert_equal environment.signup_welcome_text[:subject], environment.signup_welcome_text_subject
  end

  should 'store welcome text body' do
    environment = Environment.default

    environment.signup_welcome_text_body = 'Thanks for signing up!'
    environment.save
    environment.reload

    assert_equal environment.signup_welcome_text[:body], environment.signup_welcome_text_body
  end

  should 'allow only default languages there are defined in available locales' do
    environment = Environment.default
    environment.stubs(:available_locales).returns(['en'])
    environment.default_language = 'pt'
    environment.valid?
    assert environment.errors[:default_language.to_s].present?

    environment.default_language = 'en'
    environment.valid?
    refute environment.errors[:default_language.to_s].present?
  end

  should 'define default locale or use the config default locale' do
    environment = Environment.default
    environment.default_language = nil
    environment.save!
    assert_equal Noosfero.default_locale, environment.default_locale

    environment.default_language = 'en'
    environment.save!
    assert_equal environment.default_language, environment.default_locale
  end

  should 'allow only languages there are defined in locales' do
    environment = Environment.default

    environment.languages = ['zz']
    environment.valid?
    assert environment.errors[:languages.to_s].present?

    environment.languages = ['en']
    environment.valid?
    refute environment.errors[:languages.to_s].present?
  end

  should 'define locales or use the config locales' do
    environment = Environment.default
    environment.languages = nil
    environment.save!
    assert_equal Noosfero.locales, environment.locales

    environment.languages = ['en']
    environment.save!
    hash = {'en' => 'English'}
    assert_equal hash, environment.locales
  end

  should 'define available_locales or use the config available_locales' do
    environment = Environment.default
    environment.languages = nil
    environment.save!
    assert_equal Noosfero.available_locales, environment.available_locales

    environment.languages = ['pt', 'en']
    environment.save!
    assert_equal ['en', 'pt'], environment.available_locales
  end

  should 'not consider custom welcome screen text if not defined' do
    env = Environment.default
    refute env.has_custom_welcome_screen?
  end

  should 'not consider custom welcome screen text if nil' do
    env = Environment.default

    env.signup_welcome_screen_body = nil
    refute env.has_custom_welcome_screen?
  end

  should 'consider signup welcome screen if body is defined' do
    env = Environment.default
    env.signup_welcome_screen_body  = 'Welcome to the environment'
    assert env.has_custom_welcome_screen?
  end

  should 'store custom welcome screen body' do
    environment = Environment.default

    environment.signup_welcome_screen_body = 'Welcome to the environment'
    environment.save
    environment.reload

    assert_equal 'Welcome to the environment', environment.signup_welcome_screen_body
  end

  should 'has_license be true if there is one license in enviroment' do
    e = fast_create(Environment)
    fast_create(License, :name => 'Some', :environment_id => e.id)

    assert e.has_license?
  end

  should 'has_license be true if there is many licenses in enviroment' do
    e = fast_create(Environment)
    fast_create(License, :name => 'Some', :environment_id => e.id)
    fast_create(License, :name => 'Another', :environment_id => e.id)

    assert e.has_license?
  end

  should 'has_license be false if there is no license in enviroment' do
    e = fast_create(Environment)

    refute e.has_license?
  end

  should 'validates_inclusion_of date format' do
    environment = fast_create(Environment)

    environment.date_format = "invalid_format"
    environment.valid?
    assert environment.errors[:date_format.to_s].present?

    environment.date_format = "numbers_with_year"
    environment.valid?
    refute environment.errors[:date_format.to_s].present?

    environment.date_format = "numbers"
    environment.valid?
    refute environment.errors[:date_format.to_s].present?

    environment.date_format = "month_name_with_year"
    environment.valid?
    refute environment.errors[:date_format.to_s].present?

    environment.date_format = "month_name"
    environment.valid?
    refute environment.errors[:date_format.to_s].present?

    environment.date_format = "past_time"
    environment.valid?
    refute environment.errors[:date_format.to_s].present?
  end

  should 'respond to enable_feed_proxy' do
    assert_respond_to Environment.new, :enable_feed_proxy
  end

  should 'set enable_feed_proxy on environment' do
    e = fast_create(Environment, :name => 'Enterprise test')
    e.enable_feed_proxy = true
    e.save
    assert_equal true, e.enable_feed_proxy
  end

  should 'not enable feed proxy when enable by default' do
    assert_equal false, Environment.new.enable_feed_proxy
  end

  should 'respond to disable_feed_ssl' do
    assert_respond_to Environment.new, :disable_feed_ssl
  end

  should 'set disable_feed_ssl on environment' do
    e = fast_create(Environment, :name => 'Enterprise test')
    e.disable_feed_ssl = true
    e.save
    assert_equal true, e.disable_feed_ssl
  end

  should 'not disable feed ssl when enable by default' do
    assert_equal false, Environment.new.disable_feed_ssl
  end

  should 'respond to http_feed_proxy' do
    assert_respond_to Environment.new, :http_feed_proxy
  end

  should 'respond to https_feed_proxy' do
    assert_respond_to Environment.new, :https_feed_proxy
  end

end
