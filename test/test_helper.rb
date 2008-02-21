ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'mocha'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...

  include AuthenticatedTestHelper

  fixtures :environments, :roles
  
  def self.all_fixtures
    Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.yml')).each do |item|
      fixtures File.basename(item).sub(/\.yml$/, '').to_s
    end
  end
#  all_fixtures

  def self.should(name, &block)
    @shoulds ||= []

    destname = 'test_should_' + name.gsub(/[^a-zA-z0-9]+/, '_')
    if @shoulds.include?(destname)
      raise "there is already a test named \"#{destname}\"" 
    end

    @shoulds << destname
    if block_given?
      self.send(:define_method, destname, &block)
    else
      self.send(:define_method, destname) do
        flunk 'pending: should ' + name
      end
    end

  end

  def create_admin_user(env)
    admin_user = User.find_by_login('root') || User.create!(:login => 'root', :email => 'root@noosfero.org', :password => 'root', :password_confirmation => 'root')
    admin_role = Role.find_by_name('admin_role') || Role.create!(:name => 'admin_role', :permissions => ['view_environment_admin_panel','edit_environment_features', 'edit_environment_design', 'manage_environment_categories', 'manage_environment_roles', 'manage_environment_validators'])
    RoleAssignment.create!(:accessor => admin_user.person, :role => admin_role, :resource => env) unless admin_user.person.role_assignments.map{|ra|[ra.role, ra.accessor, ra.resource]}.include?([admin_role, admin_user, env])
    admin_user.login
  end

  def create_environment(domainname)
    env = Environment.create!(:name => domainname) 
    env.domains << Domain.new(:name => domainname)
    env.save!
    env
  end

  def create_user(name, options = {})
    data = {
      :login => name, 
      :email => name + '@noosfero.org', 
      :password => name.underscore, 
      :password_confirmation => name.underscore
    }.merge(options)
    User.create!(data)
  end

  def create_user_with_permission(name, permission, target= nil)
    user = create_user(name).person
    target ||= user
    i = 0
    while Role.find_by_name('test_role' + i.to_s)
      i+=1
    end

    role = Role.create!(:name => 'test_role' + i.to_s, :permissions => [permission])
    assert user.add_role(role, target) 
    assert user.has_permission?(permission, target)
    user
  end

  alias :ok :assert_block

  def assert_equivalent(enum1, enum2)
    assert( ((enum1 - enum2) == []) && ((enum2 - enum1) == []), "<#{enum1.inspect}> expected to be equivalent to <#{enum2.inspect}>")
  end

  def assert_includes(array, element)
    assert(array.include?(element), "<#{array.inspect}> expected to include <#{element.inspect}>")
  end

  def assert_not_includes(array, element)
    assert(!array.include?(element), "<#{array.inspect}> expected to NOT include <#{element.inspect}>")
  end

  def assert_mandatory(object, attribute, test_value = 'some random string')
    object.send("#{attribute}=", nil)
    object.valid?
    assert object.errors.invalid?(attribute), "Attribute \"#{attribute.to_s}\" expected to be mandatory."
    object.send("#{attribute}=", test_value)
    object.valid?
    assert !object.errors.invalid?(attribute), "Attribute \"#{attribute.to_s}\" expected to accept value #{test_value.inspect}"
  end

  def assert_optional(object, attribute)
    object.send("#{attribute}=", nil)
    object.valid?
    assert !object.errors.invalid?(attribute)
  end
  
  def assert_subclass(parent, child)
    assert_equal parent, child.superclass, "Class #{child} expected to be a subclass of #{parent}"
  end

  private

  def uses_host(name)
    @request.instance_variable_set('@host', name)
  end

end

class ActionController::IntegrationTest
  def login(username, password)
    post '/account/login', :login => username, :password => password
    assert_response :redirect
    follow_redirect!
    assert_not_equal '/account/login', path
  end
end

Profile
