require File.dirname(__FILE__) + '/../test_helper'
require 'catalog_controller'

# Re-raise errors caught by the controller.
class CatalogController; def rescue_action(e) raise e end; end

class CatalogControllerTest < Test::Unit::TestCase
  def setup
    @controller = CatalogController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_local_files_reference
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    assert_local_files_reference :get, :index, :profile => ent.identifier
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  should 'list products of enterprise' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    get :index, :profile => ent.identifier
    assert_tag :tag => 'h2', :content => /Catalog/
  end

  should 'show product of enterprise' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    prod = ent.products.create!(:name => 'Product test')
    get :show, :id => prod.id, :profile => ent.identifier
    assert_tag :tag => 'h2', :content => /#{prod.name}/
  end

end
