require 'test_helper'

class ActionTrackerConfigTest < ActiveSupport::TestCase

  def test_has_config
    assert_not_nil ActionTrackerConfig
  end

  def test_config_is_a_hash
    assert_kind_of Hash, ActionTrackerConfig.config
  end

  def test_config_can_be_set
    c = { :foo => 'bar' }
    ActionTrackerConfig.config = c
    assert_equal c, ActionTrackerConfig.config
  end

  def test_verbs_is_a_hash
    assert_kind_of Hash, ActionTrackerConfig.verbs
  end

  def test_verbs_can_be_set
    v = { :search => {} }
    ActionTrackerConfig.verbs = v
    assert_equal v, ActionTrackerConfig.verbs
  end

  def test_verb_names_is_a_list_of_strings
    v = { :search => {}, :delete => {}, "login" => {} }
    ActionTrackerConfig.verbs = v
    assert_equal 3, ActionTrackerConfig.verb_names.size
    %w(search delete login).each { |verb| assert ActionTrackerConfig.verb_names.include?(verb) }
  end

  def test_default_filter_time_is_after
    ActionTrackerConfig.config[:default_filter_time] = nil
    assert_equal :after, ActionTrackerConfig.default_filter_time
  end

  def test_default_filter_time_can_be_set
    ActionTrackerConfig.default_filter_time = :before
    assert_equal :before, ActionTrackerConfig.default_filter_time
  end

  def test_default_timeout_is_five_minutes
    ActionTrackerConfig.config[:timeout] = nil
    assert_equal 5.minutes, ActionTrackerConfig.timeout
  end

  def test_timeout_can_be_set
    ActionTrackerConfig.timeout = 10.minutes
    assert_equal 10.minutes, ActionTrackerConfig.timeout
  end

  def test_get_verb_return_hash
    assert_kind_of Hash, ActionTrackerConfig.get_verb(:search)
  end

  def test_get_verb_symbol_search_by_symbol
    ActionTrackerConfig.verbs = { :search => { :description => "Got it" } }
    assert_equal "Got it", ActionTrackerConfig.get_verb(:search)[:description]
  end

  def test_get_verb_symbol_search_by_string
    ActionTrackerConfig.verbs = { :search => { :description => "Got it" } }
    assert_equal "Got it", ActionTrackerConfig.get_verb("search")[:description]
  end

  def test_get_verb_string_search_by_string
    ActionTrackerConfig.verbs = { "search" => { :description => "Got it" } }
    assert_equal "Got it", ActionTrackerConfig.get_verb("search")[:description]
  end

  def test_get_verb_string_search_by_symbol
    ActionTrackerConfig.verbs = { "search" => { :description => "Got it" } }
    assert_equal "Got it", ActionTrackerConfig.get_verb(:search)[:description]
  end

  def test_default_verb_type_is_single
    ActionTrackerConfig.verbs = { "search" => { :description => "Got it" } }
    assert_equal :single, ActionTrackerConfig.verb_type(:search)
  end

  def test_verb_type_is_single_if_verb_type_not_valid
    ActionTrackerConfig.verbs = { "search" => { :type => :not_valid } }
    assert_equal :single, ActionTrackerConfig.verb_type(:search)
  end

  def test_get_verb_type_by_symbol
    ActionTrackerConfig.verbs = { "search" => { :type => :updatable } }
    assert_equal :updatable, ActionTrackerConfig.verb_type(:search)
  end

  def test_get_verb_type_by_string
    ActionTrackerConfig.verbs = { "search" => { "type" => :updatable } }
    assert_equal :updatable, ActionTrackerConfig.verb_type(:search)
  end

  def test_verb_types_is_a_list
    assert_kind_of Array, ActionTrackerConfig.verb_types
  end

  def test_valid_verb_types
    assert_equal 3, ActionTrackerConfig.verb_types.size
    assert ActionTrackerConfig.verb_types.include?(:single)
    assert ActionTrackerConfig.verb_types.include?(:updatable)
    assert ActionTrackerConfig.verb_types.include?(:groupable)
  end

end
