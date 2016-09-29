require_relative '../test_helper'

class ContentBreadcrumbsBlockTest < ActiveSupport::TestCase

  include NoosferoTestHelper

  def setup
    @profile = fast_create(Profile)
    box = Box.create!(owner: profile)
    @block = fast_create(BreadcrumbsPlugin::ContentBreadcrumbsBlock, box_id: box.id)
  end

  attr_accessor :block, :profile

  should 'has a description' do
    assert_not_equal Block.description, BreadcrumbsPlugin::ContentBreadcrumbsBlock.description
  end

  should 'has a help' do
    assert @block.help
  end

  should 'not be cacheable' do
    refute @block.cacheable?
  end

  should 'return page links in api_content' do
    folder = fast_create(Folder, profile_id: profile.id, name: 'folder')
    article = Article.create!(profile: profile, parent: folder, name: 'child')
    block.api_content_params = { page: article.path, profile: profile.identifier }
    links = block.api_content[:links]
    assert_equal [profile.name, 'folder', 'child'], links.map {|l| l[:name]}
    assert_equal article.full_path, links.last[:url]
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
    assert_equal '', render_block_content(@block)
  end
end
