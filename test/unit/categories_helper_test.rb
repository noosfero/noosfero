require File.dirname(__FILE__) + '/../test_helper'

class CategoriesHelperTest < Test::Unit::TestCase

  include CategoriesHelper

  def setup
    @environment = Environment.default
  end
  attr_reader :environment
  def _(s); s; end

  should 'generate list of category types for selection' do
    expects(:params).returns({'fieldname' => 'fieldvalue'})
    expects(:options_for_select).with([['General Category', 'Category'],[ 'Product Category', 'ProductCategory'],[ 'Region', 'Region' ]], 'fieldvalue').returns('OPTIONS')
    expects(:select_tag).with('type', 'OPTIONS').returns('TAG')
    expects(:labelled_form_field).with(anything, 'TAG').returns('RESULT')
    
    assert_equal 'RESULT', select_category_type('fieldname')
  end

end
