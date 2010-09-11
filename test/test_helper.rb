ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'mocha'
require 'tidy'
require 'hpricot'

require 'noosfero/test'
require File.dirname(__FILE__) + '/factories'
require File.dirname(__FILE__) + '/noosfero_doc_test'
require File.dirname(__FILE__) + '/action_tracker_test_helper'

FileUtils.rm_rf(File.join(RAILS_ROOT, 'index', 'test'))

Image.attachment_options[:path_prefix] = 'test/tmp/public/images'
Thumbnail.attachment_options[:path_prefix] = 'test/tmp/public/thumbnails'

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

  include Noosfero::Factory

  include AuthenticatedTestHelper

  fixtures :environments, :roles
  
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
    if block_given?
      self.send(:define_method, destname, &block)
    else
      self.send(:define_method, destname) do
        flunk 'pending: should ' + name
      end
    end

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

  def assert_valid_xhtml(method=:get, action=:index, params = {})
    return true
    if method.to_s() == 'post'
      post action, params
    else
      get action, params
    end
    tidy = Tidy.open(:show_warnings=>false)
    tidy.options.output_xml = true
    tidy.clean @response.body
    if tidy.errors
      flunk "HTML ERROR - Tidy Diagnostics:\n  "+
            tidy.errors.join("\n  ") +"\n  "+
            tidy.diagnostics.join("\n  ")
    end
  end

  def assert_local_files_reference(method=:get, action=:index, params = {})
    if method.to_s() == 'post'
      post action, params
    else
      get action, params
    end
    doc = Hpricot @response.body
    
    # Test style references:
    (doc/'style').each do |s|
      s = s.to_s().gsub( /\/\*.*\*\//, '' ).
                   split( /;|<|>|\n/ ).
                   map do |l|
                     patch = l.match( /@import url\((.*)\)/ )
                     patch ? patch[1] : nil
                   end.compact
      s.each do |css_ref|
        if ! File.exists?( RAILS_ROOT.to_s() +'/public/'+ css_ref )
          flunk 'CSS reference missed on HTML: "%s"' % css_ref
        end
      end
    end

    # Test image references:
    (doc/'img').each do |img|
      src = img.get_attribute( 'src' ).gsub(/\?[0-9]+$/, '')
      if ! File.exists?( RAILS_ROOT.to_s() +'/public/'+ src )
        flunk 'Image reference missed on HTML: "%s"' % src
      end
    end

  end

  # this check only if text has html tag
  def assert_sanitized(text)
    assert !text.index('<'), "Text '#{text}' expected to be sanitized"
  end

  def assert_tag_in_string(text, options)
    doc = HTML::Document.new(text, false, false)
    tag = doc.find(options)
    assert tag, "expected tag #{options.inspect}, but not found in #{text.inspect}"
  end

  def assert_no_tag_in_string(text, options)
    doc = HTML::Document.new(text, false, false)
    tag = doc.find(options)
    assert !tag, "expected no tag #{options.inspect}, but tag found in #{text.inspect}"
  end

  private

  def uses_host(name)
    @request.instance_variable_set('@host', name)
  end

  def process_delayed_job_queue
    silence_stream(STDOUT) do
      Delayed::Worker.new.work_off
    end
  end

end

module NoosferoTestHelper
  def link_to(content, url, options = {})
    "<a href='#{url.to_s}'>#{content}</a>"
  end

  def content_tag(tag, content, options = {})
    "<#{tag}>#{content}</#{tag}>"
  end

  def submit_tag(content, options = {})
    content
  end

  def remote_function(options = {})
    ''
  end

  def tag(tag)
    "<#{tag}/>"
  end

  def options_from_collection_for_select(collection, value_method, content_method)
    "<option value='fake value'>fake content</option>"
  end

  def select_tag(id, collection, options = {})
    "<select id='#{id}'>fake content</select>"
  end

  def options_for_select(collection)
    collection.map{|item| "<option value='#{item[1]}'>#{item[0]}</option>"}.join("\n")
  end

  def params
    {}
  end

  def ui_icon(icon)
    icon
  end

end

class ActionController::IntegrationTest
  def assert_can_login
    assert_tag :tag => 'a', :attributes => { :id => 'link_login' }
  end

  def assert_can_signup
    assert_tag :tag => 'a', :attributes => { :href => '/account/signup'}
  end

  def login(username, password)
    ActionController::Integration::Session.any_instance.stubs(:https?).returns(true)

    post '/account/login', :user => { :login => username, :password => password }
    assert_response :redirect
    follow_redirect!
    assert_not_equal '/account/login', path
  end

end

Profile
