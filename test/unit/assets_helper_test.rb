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
      expects(:link_to).with(anything, { :controller => 'search', :action => 'assets', :asset => asset})
    end

    stubs(:_).returns('')
    stubs(:content_tag).returns('')
    generate_assets_menu

  end


end
