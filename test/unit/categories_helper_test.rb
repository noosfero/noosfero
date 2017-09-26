require_relative "../test_helper"

class CategoriesHelperTest < ActiveSupport::TestCase

  include CategoriesHelper

  def setup
    @environment = Environment.default
    @plugins = mock
    @plugins.stubs(:dispatch_without_flatten).returns([])
  end
  attr_reader :environment
  def _(s); s; end

  should 'generate list of category types for selection' do
    expects(:params).returns({'fieldname' => 'fieldvalue'})
    expects(:options_for_select).with([['General category', 'Category'], [ 'Region', 'Region' ]], 'fieldvalue').returns('OPTIONS')
    expects(:select_tag).with('type', 'OPTIONS').returns('TAG')
    expects(:labelled_form_field).with(anything, 'TAG').returns('RESULT')

    assert_equal 'RESULT', select_category_type('fieldname')
  end

  should 'return a list of root categories' do
    c1 = fast_create(Category)
    c2 = fast_create(Category)
    assert_equivalent [c1, c2], root_categories_for('Category')
  end

  should 'fetch categories from the environment relation, if it exists' do
    categories = mock
    categories.stubs(:where).returns([])

    Environment.any_instance.expects(:try).with("regions").returns(categories)
    Environment.any_instance.expects(:categories).never

    root_categories_for('Region')
  end

  should 'filter categories by type, if there it is no relation with the environment' do
    categories = mock
    categories.stubs(:where).returns(categories)

    Environment.any_instance.expects(:try).returns(nil)
    Environment.any_instance.expects(:categories).returns(categories)

    root_categories_for('SomeCategoryType')
  end

  should 'return category color if its defined' do
    category1 = fast_create(Category, :name => 'education', :display_color => 'fbfbfb')
    assert_equal 'background-color: #fbfbfb;', category_color_style(category1)
  end

  should 'not return category parent color if category color is not defined' do
    e = fast_create(Environment)
    category1 = fast_create(Category, :name => 'education', :display_color => 'fbfbfb', :environment_id => e.id)
    category2 = fast_create(Category, :name => 'education', :display_color => nil, :parent_id => category1.id, :environment_id => e.id)
    assert_equal '', category_color_style(category2)
  end

  should 'not return category parent color if category is nil' do
    assert_nothing_raised do
      assert_equal '', category_color_style(nil)
    end
  end

end
