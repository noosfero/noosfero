require_relative "../test_helper"
require 'noosfero/multi_tenancy'

class MultiTenancyTest < ActiveSupport::TestCase

  def test_get_mapping_if_is_set
    mapping = { :env => {} }
    Noosfero::MultiTenancy.instance_variable_set(:@mapping, mapping)
    assert_equal mapping, Noosfero::MultiTenancy.mapping
  end

  def test_set_mapping_if_is_not_set
    mapping = { :env => {} }
    Noosfero::MultiTenancy.expects(:load_map).returns(mapping)
    Noosfero::MultiTenancy.instance_variable_set(:@mapping, nil)
    assert_equal mapping, Noosfero::MultiTenancy.mapping
    assert_equal mapping, Noosfero::MultiTenancy.instance_variable_get(:@mapping)
  end

  def test_multitenancy_is_on_if_has_mapping
    Noosfero::MultiTenancy.expects(:mapping).returns({ :env => {} })
    assert Noosfero::MultiTenancy.on?
  end

  def test_multitenancy_is_on_if_it_is_a_hosted_environment
    Noosfero::MultiTenancy.expects(:mapping).returns({})
    Noosfero::MultiTenancy.expects(:is_hosted_environment?).returns(true)
    assert Noosfero::MultiTenancy.on?
  end

  def test_multitenancy_is_off_if_it_is_not_a_hosted_environment_and_there_is_no_mapping
    Noosfero::MultiTenancy.expects(:mapping).returns({})
    Noosfero::MultiTenancy.expects(:is_hosted_environment?).returns(false)
    refute Noosfero::MultiTenancy.on?
  end

  def test_set_schema_by_host
    Noosfero::MultiTenancy.expects(:mapping).returns({ 'host' => 'schema' })
    adapter = ActiveRecord::Base.connection.class
    adapter.any_instance.expects(:schema_search_path=).with('schema').returns(true)
    assert Noosfero::MultiTenancy.db_by_host = 'host'
  end

  def test_load_map
    YAML.expects(:load_file).returns(db_config)
    assert_equal({ 'test.one.com' => 'one', 'one.com' => 'one', 'two.com' => 'two' }, Noosfero::MultiTenancy.send(:load_map))
  end

  def test_if_is_hosted_environment
    YAML.expects(:load_file).returns(db_config)
    Rails.stubs(:env).returns('one_test')
    assert Noosfero::MultiTenancy.send(:is_hosted_environment?)
  end

  def test_if_is_not_hosted_environment
    YAML.expects(:load_file).returns(db_config)
    refute Noosfero::MultiTenancy.send(:is_hosted_environment?)
  end

  private

  def db_config
    {
      'one_test' => {
        'schema_search_path' => 'one',
        'domains' => ['test.one.com', 'one.com'],
        'adapter' => 'PostgreSQL'
      },
      'two_test' => {
        'schema_search_path' => 'two',
        'domains' => ['two.com'],
        'adapter' => 'PostgreSQL'
      },
      'test' => {
        'schema_search_path' => 'public',
        'domains' => ['test.com'],
        'adapter' => 'PostgreSQL'
      },
      'production' => {
        'schema_search_path' => 'production',
        'domains' => ['production.com'],
        'adapter' => 'PostgreSQL'
      }
    }
  end

end
