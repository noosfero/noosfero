require_relative '../test_helper'

class FeaturesControllerTest < ActionDispatch::IntegrationTest

  all_fixtures
  def setup
    login_as_rails5(create_admin_user(Environment.default))
  end

  def test_listing_features
    get features_path
    assert_template 'index'
    Environment.available_features.each do |feature, text|
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "environment[enabled_features][]", :value => feature})
    end
  end

  should 'list features alphabetically' do
    Environment.expects(:available_features).returns({"c_feature" => "Starting with C", "a_feature" => "Starting with A", "b_feature" => "Starting with B"}).at_least_once
    get features_path
    assert_equal [['a_feature', 'Starting with A'], ['b_feature', 'Starting with B'], ['c_feature', 'Starting with C']], assigns(:features)
  end

  def test_updates_enabled_features
    post update_features_path, params: {:environment => { :enabled_features => [ 'feature1', 'feature2' ] }}
    assert_redirected_to :action => 'index'
    assert_kind_of String, session[:notice]
    v = Environment.default
    assert v.enabled?('feature2')
    assert v.enabled?('feature2')
    refute v.enabled?('feature3')
  end

  def test_update_disable_all
    post update_features_path
    assert_redirected_to :action => 'index'
    assert_kind_of String, session[:notice]
    v = Environment.default
    refute v.enabled?('feature1')
    refute v.enabled?('feature2')
    refute v.enabled?('feature3')
  end

  def test_update_no_post
    get update_features_path
    assert_redirected_to :action => 'index'
  end

  def test_updates_organization_approval_method
    post update_features_path, params: {:environment => { :organization_approval_method => 'region' }}
    assert_redirected_to :action => 'index'
    assert_kind_of String, session[:notice]
    v = Environment.default
    assert_equal :region, v.organization_approval_method
  end

  def test_should_mark_current_organization_approval_method_in_view
    Environment.default.update(:organization_approval_method => :region)

    post features_path

    assert_tag :tag => 'select', :attributes => { :name => 'environment[organization_approval_method]' }, :descendant => { :tag => 'option', :attributes => { :value => 'region', :selected => true } }
  end

  should 'list possible person fields' do
    Person.expects(:fields).returns(['cell_phone', 'comercial_phone']).at_least_once
    get manage_fields_features_path
    assert_template 'manage_fields'
    Person.fields.each do |field|
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "person_fields[#{field}][active]"})
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "person_fields[#{field}][required]"})
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "person_fields[#{field}][signup]"})
    end
  end

  should 'update custom_person_fields' do
    e = Environment.default
    Person.expects(:fields).returns(['cell_phone', 'comercial_phone']).at_least_once

    post manage_person_fields_features_path, params: {:person_fields => { :cell_phone => {:active => true, :required => true }}}
    assert_redirected_to :action => 'manage_fields'
    e.reload
    assert_equal true, ActiveModel::Type::Boolean.new.cast(e.custom_person_fields['cell_phone']['active'])
    assert_equal true, ActiveModel::Type::Boolean.new.cast(e.custom_person_fields['cell_phone']['required'])
  end

  should 'list possible enterprise fields' do
    Enterprise.expects(:fields).returns(['contact_person', 'contact_email']).at_least_once
    get manage_fields_features_path
    assert_template 'manage_fields'
    Enterprise.fields.each do |field|
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "enterprise_fields[#{field}][active]"})
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "enterprise_fields[#{field}][required]"})
    end
  end

  should 'update custom_enterprise_fields' do
    e = Environment.default
    Enterprise.expects(:fields).returns(['contact_person', 'contact_email']).at_least_once

    post manage_enterprise_fields_features_path, params: { :enterprise_fields => { :contact_person => {:active => true, :required => true }}}
    assert_redirected_to :action => 'manage_fields'
    e.reload
    assert_equal true, ActiveModel::Type::Boolean.new.cast(e.custom_enterprise_fields['contact_person']['active'])
    assert_equal true, ActiveModel::Type::Boolean.new.cast(e.custom_enterprise_fields['contact_person']['required'])
  end

  should 'list possible community fields' do
    Community.expects(:fields).returns(['contact_person', 'contact_email']).at_least_once
    get manage_fields_features_path
    assert_template 'manage_fields'
    Community.fields.each do |field|
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "community_fields[#{field}][active]"})
      assert_tag(:tag => 'input', :attributes => { :type => 'checkbox', :name => "community_fields[#{field}][required]"})
    end
  end

  should 'update custom_community_fields' do
    e = Environment.default
    Community.expects(:fields).returns(['contact_person', 'contact_email']).at_least_once

    post manage_community_fields_features_path, params: {:community_fields => { :contact_person => {:active => true, :required => true }}}
    assert_redirected_to :action => 'manage_fields'
    e.reload
    assert_equal true, ActiveModel::Type::Boolean.new.cast(e.custom_community_fields['contact_person']['active'])
    assert_equal true, ActiveModel::Type::Boolean.new.cast(e.custom_community_fields['contact_person']['required'])
  end

  should 'search members by name' do
    person = fast_create(Person, :environment_id => Environment.default.id)
    get search_members_features_path, params: {:q => person.name[0..2]}, xhr: true
    json_response = ActiveSupport::JSON.decode(@response.body)
    assert_includes json_response, {"id"=>person.id, "name"=>person.name}
  end

  should 'search members by identifier' do
    person = fast_create(Person, :name => 'Some Name', :identifier => 'person-identifier', :environment_id => Environment.default.id)
    get search_members_features_path, params: {:q => person.identifier}
    json_response = ActiveSupport::JSON.decode(@response.body)
    assert_includes json_response, {"id"=>person.id, "name"=>person.name}
  end

  should 'create custom field' do
    assert_nil Environment.default.custom_fields.find_by(name: 'foo')
    post manage_custom_fields_features_path, params: { :customized_type => 'Person', :custom_fields => {
      Time.now.to_i => {
        :name => 'foo',
        :default_value => 'foobar',
        :format => 'string',
        :customized_type => 'Person',
        :active => true,
        :required => true,
        :signup => true
      }
    }}
    assert_redirected_to :action => 'manage_fields'
    assert_not_nil Environment.default.custom_fields.find_by(name: 'foo')
  end

  should 'update custom field' do

    field = CustomField.create! :name => 'foo', :default_value => 'foobar', :format => 'string', :extras => '', :customized_type => 'Enterprise', :active => true, :required => true, :signup => true, :environment => Environment.default
    post manage_custom_fields_features_path, params: {:customized_type => 'Enterprise', :custom_fields => {
      field.id => {
        :name => 'foo bar',
        :default_value => 'foobar',
        :active => true,
        :required => true,
        :signup => true
      }
    }}
    field.reload
    assert_redirected_to :action => 'manage_fields'
    assert_equal 'foo bar', field.name
  end

  should 'destroy custom field' do

    field = CustomField.create! :name => 'foo', :default_value => 'foobar', :format => 'string', :extras => '', :customized_type => 'Enterprise', :active => true, :required => true, :signup => true, :environment => Environment.default

    post manage_custom_fields_features_path, params: {:customized_type => 'Enterprise'}

    assert_redirected_to :action => 'manage_fields'
    assert_nil Environment.default.custom_fields.find_by(name: 'foo')
  end

end
