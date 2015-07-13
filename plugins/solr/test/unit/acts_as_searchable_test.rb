require_relative '../test_helper'
require "#{File.dirname(__FILE__)}/../../lib/acts_as_searchable"

class ActsAsSearchableTest < ActiveSupport::TestCase

  def setup
		@test_model = Class.new ActiveRecord::Base
	end

  def silent
		# http://mentalized.net/journal/2010/04/02/suppress_warnings_from_ruby/
		original_verbosity = $VERBOSE
    $VERBOSE = nil
    result = yield
    $VERBOSE = original_verbosity
    return result
  end

	should 'be enabled by default' do
		assert ActsAsSearchable::ClassMethods::ACTS_AS_SEARCHABLE_ENABLED, true
  end

  should 'not be searchable when disabled' do
		# suppress warning about already initialized constant
		silent { ActsAsSearchable::ClassMethods::ACTS_AS_SEARCHABLE_ENABLED = false }
		
    @test_model.expects(:acts_as_solr).never
		@test_model.acts_as_searchable
  end

  should 'correctly pass options to search engine' do
    options = {:fields => [{:name => :text}]}
		@test_model.expects(:acts_as_solr).with(options)
		@test_model.acts_as_searchable options
  end

	should 'always include schema name as a field' do
		@test_model.expects(:acts_as_solr).with(has_entry(:fields, [{:field1 => :text}, {:schema_name => :string}]))
		@test_model.acts_as_searchable :fields => [{:field1 => :text}]
		# ...even with no fields
		@test_model = Class.new ActiveRecord::Base
		@test_model.expects(:acts_as_solr).with(has_entry(:additional_fields, [{:schema_name => :string}]))
		@test_model.acts_as_searchable
  end

end
