ENV["RAILS_ENV"] = "test"
require "simplecov"
require "test_helper"
require_relative "../config/environment"

require "rails/test_help"

require "mocha"
require "mocha/minitest"
require "minitest/spec"
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new, ENV, Minitest.backtrace_filter

require_relative "mocks/environment"
require_relative "mocks/profile"
require_relative "mocks/test_controller"
require_relative "mocks/uploaded_file"

require_relative "support/should"
require_relative "support/factories"
require_relative "support/integration_test"
require_relative "support/controller_test_case"
require_relative "support/authenticated_test_helper"
require_relative "support/action_tracker_test_helper"
require_relative "support/noosfero_doc_test"
require_relative "support/performance_helper"
require_relative "support/noosfero_test_helper"

FileUtils.rm_rf(Rails.root.join("index", "test"))

Image.attachment_options[:path_prefix] = "test/tmp/public/images"
Thumbnail.attachment_options[:path_prefix] = "test/tmp/public/thumbnails"

FastGettext.add_text_domain "noosferotest", type: :chain, chain: []
FastGettext.default_text_domain = "noosferotest"
DatabaseCleaner.strategy = :transaction

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
  self.use_transactional_tests = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures = false

  extend Test::Should

  include ActionDispatch::TestProcess
  include Noosfero::Factory
  include AuthenticatedTestHelper
  include PerformanceHelper
  include ApplicationHelper

  fixtures :environments, :roles

  def self.all_fixtures
    Dir.glob(Rails.root.join("test", "fixtures", "*.yml")).each do |item|
      fixtures File.basename(item).sub(/\.yml$/, "").to_s
    end
  end

  # deprecated on minitest
  def assert_block(message = nil)
    assert message || "yield" do
      yield
    end
  end
  alias_method :ok, :assert_block

  setup :global_setup

  def global_setup
    User.current = nil
    Delayed::Job.destroy_all
  end

  alias :ok :assert_block

  def assert_equivalent(enum1, enum2)
    norm1 = enum1.group_by { |e| e }.values
    norm2 = enum2.group_by { |e| e }.values
    assert_equal norm1.size, norm2.size, "Size mismatch: #{enum1.inspect} vs #{enum2.inspect}"
    assert_equal [], norm1 - norm2, "Arrays #{norm1} and #{norm2} are not equivalents"
    assert_equal [], norm2 - norm1, "Arrays #{norm1} and #{norm2} are not equivalents"
  end

  def assert_mandatory(object, attribute, test_value = "some random string")
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
    assert !text.index("<"), "Text '#{text}' expected to be sanitized"
  end

  def assert_tag_in_string(text, options)
    doc = HTML::Document.new(text)
    tag = doc.find(options)
    assert tag, "expected tag #{options.inspect}, but not found in #{text.inspect}"
  end

  def assert_no_tag_in_string(text, options)
    doc = HTML::Document.new(text)
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

  def h2s(value) # make a string from ordered hash to simplify tests
    case value
    when Hash, HashWithIndifferentAccess
      "{" + value.stringify_keys.to_a.sort { |a, b| a[0] <=> b[0] }.map { |k, v| k + ":" + h2s(v) }.join(",") + "}"
    when Array
      "[" + value.map { |i| h2s(i) }.join(",") + "]"
    when NilClass
      "<nil>"
    else value.to_s
    end
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

  def render(*args)
    self.class.action_view.render(*args)
  end

  def url_for(args = {})
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
      # @request.instance_variable_set('@host', name)
      @request.host = name
    end

    def process_delayed_job_queue
      # To enable logs, add `(quiet: false)` to Delayed::Worker.new
      Delayed::Worker.new(quiet: true).work_off
    end

    def uses_postgresql(schema_name = "test_schema")
      adapter = ApplicationRecord.connection.class
      adapter.any_instance.stubs(:adapter_name).returns("PostgreSQL")
      adapter.any_instance.stubs(:schema_search_path).returns(schema_name)
      Noosfero::MultiTenancy.stubs(:on?).returns(true)
    end

    def uses_sqlite
      adapter = ApplicationRecord.connection.class
      adapter.any_instance.stubs(:adapter_name).returns("SQLite")
      Noosfero::MultiTenancy.stubs(:on?).returns(false)
    end

    def unsafe(string)
      ret = ActiveSupport::SafeBuffer.new(string)
      ret.instance_eval { @html_safe = false }
      ret
    end

    def json_response
      ActiveSupport::JSON.decode(@response.body)
    end

    def set_profile_field_privacy(profile, field, privacy = "private_content")
      environment = profile.environment
      environment.send("custom_#{profile.type.downcase}_fields=", field => { "active" => "true" })
      environment.save!
      profile.fields_privacy = { field => privacy }
      profile.save!
    end

    def mock_all_profile_image(size, image, image_data)
      Profile.any_instance.stubs(:image).returns(image)
      Image.any_instance.stubs(:data).with(size).returns(image_data)
    end

    def get_profile_image_from_api(size, profile_identifier)
      profile = fast_create(Person, identifier: profile_identifier)
      params[:key] = :identifier
      get "/api/v1/profiles/#{profile_identifier}/#{size}?#{params.to_query}"
      data = last_response.body
    end

    def create_base64_image
      image_path = File.absolute_path(Rails.root + "public/images/noosfero-network.png")
      image_name = File.basename(image_path)
      image_type = "image/#{File.extname(image_name).delete "."}"
      encoded_base64_img = Base64.encode64(File.open(image_path) { |io| io.read })
      base64_image = {}
      base64_image[:tempfile] = encoded_base64_img
      base64_image[:filename] = image_name
      base64_image[:type] = image_type
      base64_image
    end

    # DEPRECATED/REMOVED METHODS
    def clean_backtrace(&block)
      yield
    rescue ActiveModel::Errors => e
      path = File.expand_path(__FILE__)
      raise ActiveModel::Errors, e.message, e.backtrace.reject { |line| File.expand_path(line) =~ /#{path}/ }
    end

    def find_tag(conditions)
      html_document.find(conditions)
    end

    def assert_tag(*opts)
      clean_backtrace do
        opts = opts.size > 1 ? opts.last.merge(tag: opts.first.to_s) : opts.first
        tag = find_tag(opts)
        assert tag, "expected tag, but no tag found matching #{opts.inspect} in:\n#{@response.body.inspect}"
      end
    end

    def assert_no_tag(*opts)
      clean_backtrace do
        opts = opts.size > 1 ? opts.last.merge(tag: opts.first.to_s) : opts.first
        tag = find_tag(opts)
        assert !tag, "expected no tag, but found tag matching #{opts.inspect} in:\n#{@response.body.inspect}"
      end
    end
end
