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

  def self.all_fixtures
    Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.yml')).each do |item|
      fixtures File.basename(item).sub(/\.yml$/, '').to_s
    end
  end

  def self.should(name, &block)
    @shoulds ||= []

    destname = 'test_should_' + name.gsub(/[^a-zA-z0-9]+/, '_')
    if @shoulds.include?(destname)
      raise "there is already a test named \"#{destname}\"" 
    end

    @shoulds << destname
    self.send(:define_method, destname, &block)

  end

  def self.extra_parameters
    @extra_parameters
  end

  def self.add_extra_parameter(name, value)
    @extra_parameters ||= {}
    @extra_parameters[name] = value.to_s
    self.send(:include, NoosferoTest)  unless self.include?(NoosferoTest)
  end

  def self.under_profile(profile_identifier)
    add_extra_parameter(:profile, profile_identifier)
    raise "profile_identifier must be set!" unless extra_parameters[:profile]
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
    assert_equal '/account', path
  end
end
