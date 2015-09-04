ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'
require 'mocha'

require 'noosfero/test'
require 'authenticated_test_helper'
require File.dirname(__FILE__) + '/factories'
require File.dirname(__FILE__) + '/noosfero_doc_test'
require File.dirname(__FILE__) + '/action_tracker_test_helper'

FileUtils.rm_rf(Rails.root.join('index', 'test'))

Image.attachment_options[:path_prefix] = 'test/tmp/public/images'
Thumbnail.attachment_options[:path_prefix] = 'test/tmp/public/thumbnails'

FastGettext.add_text_domain 'noosferotest', :type => :chain, :chain => []
FastGettext.default_text_domain = 'noosferotest'

class ActiveSupport::TestCase
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

  # for fixture_file_upload
  include ActionDispatch::TestProcess

  include Noosfero::Factory

  include AuthenticatedTestHelper

  fixtures :environments, :roles

  def self.all_fixtures
    Dir.glob(Rails.root.join('test', 'fixtures', '*.yml')).each do |item|
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

  setup :global_setup

  def global_setup
    User.current = nil
  end

  alias :ok :assert_block

  def assert_equivalent(enum1, enum2)
    assert( ((enum1 - enum2) == []) && ((enum2 - enum1) == []), "<#{enum1.inspect}> expected to be equivalent to <#{enum2.inspect}>")
  end

  def assert_mandatory(object, attribute, test_value = 'some random string')
    object.send("#{attribute}=", nil)
    object.valid?
    assert object.errors[attribute.to_s].present?, "Attribute \"#{attribute.to_s}\" expected to be mandatory."
    object.send("#{attribute}=", test_value)
    object.valid?
    assert !object.errors[attribute.to_s].present?, "Attribute \"#{attribute.to_s}\" expected to accept value #{test_value.inspect}"
  end

  def assert_optional(object, attribute)
    object.send("#{attribute}=", nil)
    object.valid?
    assert !object.errors[attribute.to_s].present?
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

  def assert_order(reference, original)
    original.each do |value|
      if reference.include?(value)
        if reference.first == value
          reference.shift
        else
          assert false, "'#{value.inspect}' was found before it should be on: #{original.inspect}"
        end
      end
    end
    assert reference.blank?, "The following elements are not in the collection: #{reference.inspect}"
  end

  # For models that render views (blocks, articles, ...)
  def self.action_view
    @action_view ||= begin
      view_paths = ActionController::Base.view_paths
      action_view = ActionView::Base.new view_paths, {}
      # for using Noosfero helpers inside render calls
      action_view.extend ApplicationHelper
      action_view
    end
  end

  def render *args
    self.class.action_view.render(*args)
  end

  def url_for args = {}
    args
  end

  # url_for inside views (partials)
  # from http://stackoverflow.com/a/13704257/670229
  ActionView::TestCase::TestController.instance_eval do
    helper Noosfero::Application.routes.url_helpers
  end
  ActionView::TestCase::TestController.class_eval do
    def _routes
      Noosfero::Application.routes
    end
  end

  private

  def uses_host(name)
    #@request.instance_variable_set('@host', name)
    @request.host = name
  end

  def process_delayed_job_queue
    silence_stream(STDOUT) do
      Delayed::Worker.new.work_off
    end
  end

  def uses_postgresql(schema_name = 'test_schema')
    adapter = ActiveRecord::Base.connection.class
    adapter.any_instance.stubs(:adapter_name).returns('PostgreSQL')
    adapter.any_instance.stubs(:schema_search_path).returns(schema_name)
    Noosfero::MultiTenancy.stubs(:on?).returns(true)
  end

  def uses_sqlite
    adapter = ActiveRecord::Base.connection.class
    adapter.any_instance.stubs(:adapter_name).returns('SQLite')
    Noosfero::MultiTenancy.stubs(:on?).returns(false)
  end

  def unsafe(string)
    ret = ActiveSupport::SafeBuffer.new(string)
    ret.instance_eval { @html_safe = false }
    ret
  end

end

module NoosferoTestHelper
  def link_to(content, url, options = {})
    "<a href='#{url.inspect}'>#{content}</a>"
  end

  def content_tag(tag, content, options = {})
    tag_attr = options.blank? ? '' : ' ' + options.collect{ |o| "#{o[0]}=\"#{o[1]}\"" }.join(' ')
    "<#{tag}#{tag_attr}>#{content}</#{tag}>"
  end

  def submit_tag(content, options = {})
    content
  end

  def remote_function(options = {})
    ''
  end

  def tag(tag, args = {})
    attrs = args.map{|k,v| "#{k}='#{v}'"}.join(' ')
    "<#{tag} #{attrs} />"
  end

  def options_from_collection_for_select(collection, value_method, content_method)
    "<option value='fake value'>fake content</option>"
  end

  def select_tag(id, collection, options = {})
    "<select id='#{id}'>fake content</select>"
  end

  def options_for_select(collection, selected = nil)
    collection.map{|item| "<option value='#{item[1]}'>#{item[0]}</option>"}.join("\n")
  end

  def params
    {}
  end

  def ui_icon(icon)
    icon
  end

  def will_paginate(arg1, arg2)
  end

  def javascript_tag(any)
    ''
  end
  def javascript_include_tag(any)
    ''
  end
  def check_box_tag(name, value = 1, checked = false, options = {})
    name
  end
  def stylesheet_link_tag(arg)
    arg
  end

  def strip_tags(html)
    html.gsub(/<[^>]+>/, '')
  end

  def icon_for_article(article)
    ''
  end

  # make a string from ordered hash to simplify tests
  def h2s(value)
    case value
      when Hash, HashWithIndifferentAccess
        '{'+ value.stringify_keys.to_a.sort{|a,b|a[0]<=>b[0]}.map{ |k,v| k+':'+h2s(v) }.join(',') +'}'
      when Array
        '['+ value.map{|i|h2s(i)}.join(',') +']'
      when NilClass
        '<nil>'
      else value.to_s
    end
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
