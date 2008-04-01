require File.dirname(__FILE__) + '/../test_helper'

class ApplicationHelperTest < Test::Unit::TestCase

  include AssetsHelper

  should 'generate link to assets' do
    %w[ articles
        people
        products
        enterprises
        communities
        comments
    ].each do |asset|
      expects(:link_to).with(anything, { :controller => 'search', :action => 'assets', :asset => asset, :category_path => []})
    end

    stubs(:_).returns('')
    stubs(:content_tag).returns('')
    generate_assets_menu
  end

  should 'generate link to assets with current category' do
    %w[ articles
        people
        products
        enterprises
        communities
        comments
    ].each do |asset|
      expects(:link_to).with(anything, { :controller => 'search', :action => 'assets', :asset => asset, :category_path => [ 'my-category' ]})
    end

    stubs(:_).returns('')
    stubs(:content_tag).returns('')
    @category = mock
    @category.expects(:explode_path).returns(['my-category']).at_least_once
    generate_assets_menu
  end

end
