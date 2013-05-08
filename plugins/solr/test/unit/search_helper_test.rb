require "#{File.dirname(__FILE__)}/../test_helper"

class SearchHelperTest < ActiveSupport::TestCase

  include SolrPlugin::SearchHelper

  should 'display facets menu' do
    expects(:asset_class).with('asset')
    expects(:render).with(:partial => 'facets_menu')
    facets_menu 'asset', nil
  end

  should 'display facets_unselect menu' do
    expects(:asset_class).with('asset')
    expects(:render).with(:partial => 'facets_unselect_menu')
    facets_unselect_menu 'asset'
  end

  should 'display facets javascript' do
    expects(:text_field_tag).returns('<text_field_tag_return>')
    expects(:javascript_tag).with(regexp_matches(/id.*[\'array_item\'].*json_message/m)).returns(
      '<javascript_tag_return>')
    stubs(:jquery_token_input_messages_json).returns('json_message')
    assert_equal '<text_field_tag_return><javascript_tag_return>',
      facet_javascript('id', '', ['array_item'])
  end

  should 'display empty array in facets javascript if array is nil' do
    expects(:text_field_tag).returns('<text_field_tag_return>')
    expects(:javascript_tag).with(regexp_matches(/id.*\[\].*json_message/m)).returns(
      '<javascript_tag_return>')
    stubs(:jquery_token_input_messages_json).returns('json_message')
    assert_equal '<text_field_tag_return><javascript_tag_return>',
      facet_javascript('id', '', [])
  end

  should 'return html code for facet link' do
    facet = {
      :solr_field => 'facet_solr_field',
      :label_id => 'facet_label_id'
    }
    params = {}
    value = 'facet_value'
    label = 'facet_label'
    count = 1

    expected_url = {:facet => {'facet_solr_field' => { 'facet_label_id' => ['facet_value']}}}

    expects(:link_to).with('facet_label', expected_url, anything).returns('<link_to_result>')
    stubs(:content_tag).with(anything, '', anything).returns('<content_tag_extra>')
    stubs(:content_tag).with(anything, ' (1)', anything).returns('<content_tag_count>')
    stubs(:content_tag).with(anything, '<link_to_result><content_tag_extra><content_tag_count>', anything).returns('<content_tag_final_result>')

    assert_equal '<content_tag_final_result>',
      facet_link_html(facet, params, value, label, count)
  end

  should 'return html code for facet link with extra label' do
    facet = {
      :solr_field => 'facet_solr_field',
      :label_id => 'facet_label_id'
    }
    params = {}
    value = 'facet_value'
    label = ['facet_label', 'facet_extra']
    count = 1

    expected_url = {:facet => {'facet_solr_field' => { 'facet_label_id' => ['facet_value']}}}

    expects(:link_to).with('facet_label', expected_url, anything).returns('<link_to_result>')
    stubs(:content_tag).with(anything, 'facet_extra', anything).returns('<content_tag_extra>')
    stubs(:content_tag).with(anything, ' (1)', anything).returns('<content_tag_count>')
    stubs(:content_tag).with(anything, '<link_to_result><content_tag_extra><content_tag_count>', anything).returns('<content_tag_final_result>')

    assert_equal '<content_tag_final_result>',
      facet_link_html(facet, params, value, label, count)
  end

  should 'return html code for selected facet link' do
    facet = {
      :solr_field => 'facet_solr_field'
    }
    params = {:facet => {'facet_solr_field' => 'facet_value'}}
    value = 'facet_value'
    label = 'facet_label'
    count = 1

    expected_url = {:facet => {'facet_solr_field' => 'facet_value'}}

    expects(:link_to).with('facet_label', expected_url, anything).returns('<link_to_result>')
    stubs(:content_tag).with(anything, '', anything).returns('<content_tag_extra>')
    stubs(:content_tag).with(anything, ' (1)', anything).returns('<content_tag_count>')
    stubs(:content_tag).with(anything, '<link_to_result><content_tag_extra><content_tag_count>', {:class => 'facet-menu-item facet-result-link-selected'}).returns('<content_tag_final_result>')

    assert_equal '<content_tag_final_result>',
      facet_link_html(facet, params, value, label, count)
  end

  should 'show html for non-hash selected facets' do
    klass = mock
    klass.stubs(:facet_by_id).with(:facet_id).returns('klass_facet_by_id')
    klass.stubs(:facet_label).with('klass_facet_by_id').returns('klass_facet_label')
    klass.stubs(:facet_result_name).with('klass_facet_by_id', 'facet_value').returns('klass_facet_result_name')
    params = {:facet => {:facet_id => 'facet_value'}}

    expects(:content_tag).with(anything, 'klass_facet_label', anything).returns('<content_tag_label>')
    expects(:content_tag).with(anything, 'klass_facet_result_name', anything).returns('<content_tag_name>')
    expects(:link_to).with(anything, {:facet => {}}, anything).returns('<link_to_url>')
    expects(:content_tag).with(anything, '<content_tag_label><content_tag_name><link_to_url>', anything).returns('<final_content>')

    environment = mock
    assert_match '<final_content>', facet_selecteds_html_for(environment, klass, params)
  end

  should 'show select tag for order_by' do
    [:products, :events, :articles, :enterprises, :people, :communities].each do |asset|
      params = {:order_by => 'Relevance'}

      stubs(:params).returns(params)
			stubs(:logged_in?).returns(false)
      stubs(:options_for_select).with(instance_of(Array), params[:order_by]).returns('<options_for_select>')
      stubs(:select_tag).with(regexp_matches(/#{asset}/), '<options_for_select>', anything).returns('<select_tag>')
      expects(:content_tag).with(anything, regexp_matches(/<select_tag>/), anything).returns('<final_content>')

      assert_equal '<final_content>', order_by(asset)
    end
  end

  should 'show total of assets found' do
    [:products, :events, :articles, :enterprises, :people, :communities].each do |asset|
      expects(:content_tag).with(anything, regexp_matches(/10.*#{asset}.*found/), anything).returns('<final_content>')
      assert_equal '<final_content>', label_total_found(asset, 10)
    end
  end

end

