require_relative "../test_helper"

class EnterpriseHomepageTest < ActiveSupport::TestCase
  
  def setup
    @profile = create_user('testing').person
    @product_category = fast_create(ProductCategory, :name => 'Products')
  end
  attr_reader :profile

  should 'provide a proper short description' do
    assert_kind_of String, EnterpriseHomepage.short_description
  end

  should 'provide a proper description' do
    assert_kind_of String, EnterpriseHomepage.description
  end

  should 'return a valid body' do
    e = EnterpriseHomepage.new(:name => 'sample enterprise homepage')
    assert_not_nil e.to_html
  end

  should 'can display hits' do
    a = EnterpriseHomepage.new(:name => 'Test article')
    assert_equal false, a.can_display_hits?
  end

  should 'have can_display_media_panel with default true' do
    a = EnterpriseHomepage.new
    assert a.can_display_media_panel?
  end

end
