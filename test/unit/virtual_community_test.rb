require File.dirname(__FILE__) + '/../test_helper'

class VirtualCommunityTest < Test::Unit::TestCase
  fixtures :virtual_communities

  def test_exists_default_and_it_is_unique
    VirtualCommunity.delete_all
    vc = VirtualCommunity.new(:name => 'Test Community')
    vc.is_default = true
    assert vc.save

    vc2 = VirtualCommunity.new(:name => 'Another Test Community')
    vc2.is_default = true
    assert !vc2.valid?
    assert vc2.errors.invalid?(:is_default)

    assert_equal vc, VirtualCommunity.default
  end

  def test_acts_as_configurable
    vc = VirtualCommunity.new(:name => 'Testing VirtualCommunity')
    assert_kind_of Hash, vc.settings
    vc.settings[:some_setting] = 1
    assert vc.save
    assert_equal 1, vc.settings[:some_setting]
  end

  def test_available_features
    assert_kind_of Hash, VirtualCommunity.available_features
  end

  def test_mock
    assert_equal ['feature1', 'feature2', 'feature3'], VirtualCommunity.available_features.keys.sort
  end

  def test_features
    v = virtual_communities(:colivre_net)
    v.enable('feature1')
    assert v.enabled?('feature1')
    v.disable('feature1')
    assert !v.enabled?('feature1')
  end

  def test_enabled_features
    v = virtual_communities(:colivre_net)
    v.enabled_features = [ 'feature1', 'feature2' ]
    assert v.enabled?('feature1') && v.enabled?('feature2') && !v.enabled?('feature3')
  end

  def test_enabled_features_no_features_enabled
    v = virtual_communities(:colivre_net)
    v.enabled_features = nil
    assert !v.enabled?('feature1') && !v.enabled?('feature2') && !v.enabled?('feature3')
  end

  def test_name_is_mandatory
    v = VirtualCommunity.new
    v.valid?
    assert v.errors.invalid?(:name)
    v.name = 'blablabla'
    v.valid?
    assert !v.errors.invalid?(:name)
  end

  def test_terms_of_use
    v = VirtualCommunity.new(:name => 'My test virtual community')
    assert_nil v.terms_of_use
    v.terms_of_use = 'To be part of this virtual community, you must accept the following terms: ...'
    assert v.save
    id = v.id
    assert_equal 'To be part of this virtual community, you must accept the following terms: ...', VirtualCommunity.find(id).terms_of_use
  end

  def test_has_terms_of_use
    v = VirtualCommunity.new
    assert !v.has_terms_of_use?
    v.terms_of_use = 'some terms of use'
    assert v.has_terms_of_use?
  end

  def test_should_profive_flexible_template_stuff
    v = VirtualCommunity.new

    # template
    assert_nil v.flexible_template_template
    v.flexible_template_template = 'bli'
    assert_equal 'bli', v.flexible_template_template

    # theme
    assert_nil v.flexible_template_theme
    v.flexible_template_theme = 'bli'
    assert_equal 'bli', v.flexible_template_theme
    
    # icon theme
    assert_nil v.flexible_template_icon_theme
    v.flexible_template_icon_theme = 'bli'
    assert_equal 'bli', v.flexible_template_icon_theme
  end

end
