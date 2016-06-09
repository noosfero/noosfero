require "#{File.dirname(__FILE__)}/../../test_helper"

class ElasticsearchPluginControllerTest < ActionController::TestCase
  def setup
    start_cluster
  end

  def teardown
    stop_cluster
  end

  should 'work and uses control filter variables' do
    get :index 
    assert_response :success
    assert_not_nil assigns(:searchable_types)
    assert_not_nil assigns(:selected_type)
    assert_not_nil assigns(:search_filter_types)
    assert_not_nil assigns(:selected_filter_field)
  end

  should 'return all results if selected_type is nil' do
    get :index, {'selected_type' => :person, :q => 'John'} 
    assert_response :success
    assert_tag tag: "div", attributes: { class: "results" },
      children: { count: 2 }
  end

end
