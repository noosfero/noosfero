require File.dirname(__FILE__) + '/../test_helper'

class EnvironmentTest < Test::Unit::TestCase
  fixtures :environments

  def test_exists_default_and_it_is_unique
    Environment.delete_all
    vc = Environment.new(:name => 'Test Community')
    vc.is_default = true
    assert vc.save

    vc2 = Environment.new(:name => 'Another Test Community')
    vc2.is_default = true
    assert !vc2.valid?
    assert vc2.errors.invalid?(:is_default)

    assert_equal vc, Environment.default
  end

  def test_acts_as_configurable
    vc = Environment.new(:name => 'Testing Environment')
    assert_kind_of Hash, vc.settings
    vc.settings[:some_setting] = 1
    assert vc.save
    assert_equal 1, vc.settings[:some_setting]
  end

  def test_available_features
    assert_kind_of Hash, Environment.available_features
  end

  def test_mock
    assert_equal ['feature1', 'feature2', 'feature3'], Environment.available_features.keys.sort
  end

  def test_features
    v = environments(:colivre_net)
    v.enable('feature1')
    assert v.enabled?('feature1')
    v.disable('feature1')
    assert !v.enabled?('feature1')
  end

  def test_enabled_features
    v = environments(:colivre_net)
    v.enabled_features = [ 'feature1', 'feature2' ]
    assert v.enabled?('feature1') && v.enabled?('feature2') && !v.enabled?('feature3')
  end

  def test_enabled_features_no_features_enabled
    v = environments(:colivre_net)
    v.enabled_features = nil
    assert !v.enabled?('feature1') && !v.enabled?('feature2') && !v.enabled?('feature3')
  end

  def test_name_is_mandatory
    v = Environment.new
    v.valid?
    assert v.errors.invalid?(:name)
    v.name = 'blablabla'
    v.valid?
    assert !v.errors.invalid?(:name)
  end

  def test_terms_of_use
    v = Environment.new(:name => 'My test environment')
    assert_nil v.terms_of_use
    v.terms_of_use = 'To be part of this environment, you must accept the following terms: ...'
    assert v.save
    id = v.id
    assert_equal 'To be part of this environment, you must accept the following terms: ...', Environment.find(id).terms_of_use
  end

  def test_has_terms_of_use
    v = Environment.new
    assert !v.has_terms_of_use?
    v.terms_of_use = 'some terms of use'
    assert v.has_terms_of_use?
  end

  def test_should_profive_flexible_template_stuff
    v = Environment.new

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

  def test_should_list_top_level_categories
    env = Environment.create!(:name => 'a test environment')
    cat1 = Category.create!(:name => 'first category', :environment_id => env.id)
    cat2 = Category.create!(:name => 'second category', :environment_id => env.id)
    subcat = Category.create!(:name => 'child category', :environment_id => env.id, :parent_id => cat2.id)

    cats = env.top_level_categories
    assert_equal 2, cats.size
    assert cats.include?(cat1)
    assert cats.include?(cat2)
    assert !cats.include?(subcat)
  end

  def test_should_list_all_categories
    env = Environment.create!(:name => 'a test environment')
    cat1 = Category.create!(:name => 'first category', :environment_id => env.id)
    cat2 = Category.create!(:name => 'second category', :environment_id => env.id)
    subcat = Category.create!(:name => 'child category', :environment_id => env.id, :parent_id => cat2.id)

    cats = env.categories
    assert_equal 3, cats.size
    assert cats.include?(cat1)
    assert cats.include?(cat2)
    assert cats.include?(subcat)
  end

  should 'list displayable categories' do
    env = Environment.create!(:name => 'a test environment')
    cat1 = env.categories.create(:name => 'category one', :display_color => 1)
    assert ! cat1.new_record?

    # subcategories should be ignored
    subcat1 = env.categories.create(:name => 'subcategory one', :parent_id => cat1.id)
    assert ! subcat1.new_record?

    cat2 = env.categories.create(:name => 'category two')
    assert !cat2.new_record?

    assert_equal 1,  env.display_categories.size
    assert env.display_categories.include?(cat1)
    assert !env.display_categories.include?(cat2)
  end

end
