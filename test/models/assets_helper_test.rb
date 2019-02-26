require_relative "../test_helper"

class AssetsHelperTest < ActiveSupport::TestCase

  include AssetsHelper

  should 'generate link to assets' do
    env = mock; env.stubs(:enabled?).with(anything).returns(false)
    stubs(:environment).returns(env)

    %w[ articles
        people
        products
        enterprises
        communities
        events
    ].each do |asset|
      expects(:link_to).with(anything, { :controller => 'search', :action => 'assets', :asset => asset, :category_path => []})
    end

    stubs(:_).returns('')
    stubs(:__).returns('')
    stubs(:content_tag).returns('')
    generate_assets_menu
  end

  should 'generate link to assets with current category' do
    env = mock; env.stubs(:enabled?).with(anything).returns(false)
    stubs(:environment).returns(env)

    %w[ articles
        people
        products
        enterprises
        communities
        events
    ].each do |asset|
      expects(:link_to).with(anything, { :controller => 'search', :action => 'assets', :asset => asset, :category_path => [ 'my-category' ]})
    end

    stubs(:_).returns('')
    stubs(:__).returns('')
    stubs(:content_tag).returns('')
    @category = mock
    @category.expects(:explode_path).returns(['my-category']).at_least_once
    generate_assets_menu
  end

  should 'generate link only to non-disabled assets' do
    env = mock
    env.expects(:enabled?).with('disable_asset_articles').returns(false)
    env.expects(:enabled?).with('disable_asset_enterprises').returns(true)
    env.expects(:enabled?).with('disable_asset_people').returns(false)
    env.expects(:enabled?).with('disable_asset_communities').returns(false)
    env.expects(:enabled?).with('disable_asset_products').returns(true)
    env.expects(:enabled?).with('disable_asset_events').returns(false)
    stubs(:environment).returns(env)

    %w[ articles
        people
        communities
        events
    ].each do |asset|
      expects(:link_to).with(anything, { :controller => 'search', :action => 'assets', :asset => asset, :category_path => [ 'my-category' ]})
    end
    expects(:link_to).with(anything, { :controller => 'search', :action => 'assets', :asset => 'products', :category_path => [ 'my-category' ]}).never
    expects(:link_to).with(anything, { :controller => 'search', :action => 'assets', :asset => 'enterprises', :category_path => [ 'my-category' ]}).never

    stubs(:_).returns('')
    stubs(:__).returns('')
    stubs(:content_tag).returns('')
    @category = mock
    @category.expects(:explode_path).returns(['my-category']).at_least_once

    generate_assets_menu
  end

end
