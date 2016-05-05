require_relative '../test_helper'

class ContentBreadcrumbsBlockTest < ActiveSupport::TestCase

  include NoosferoTestHelper

  def setup
    @block = BreadcrumbsPlugin::ContentBreadcrumbsBlock.new
  end

  should 'has a description' do
    assert_not_equal Block.description, BreadcrumbsPlugin::ContentBreadcrumbsBlock.description
  end

  should 'has a help' do
    assert @block.help
  end


  should 'not be cacheable' do
    refute @block.cacheable?
  end

end

require 'boxes_helper'

class ContentBreadcrumbsBlockViewTest < ActionView::TestCase
  include BoxesHelper

  def setup
    @block = BreadcrumbsPlugin::ContentBreadcrumbsBlock.new
    @profile = fast_create(Community)
    @folder = fast_create(Folder, :profile_id => @profile.id)
    @article = fast_create(Folder, :profile_id => @profile.id, :parent_id => @folder.id)
  end

  should 'render trail if there is links to show' do
    @page = @article
    trail = render_block_content(@block)
    assert_match /#{@profile.name}/, trail
    assert_match /#{@folder.name}/, trail
    assert_match /#{@page.name}/, trail
  end

  should 'render nothing if there is no links to show' do
    @page = nil
    assert_equal "\n", render_block_content(@block)
  end
end
