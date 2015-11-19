require_relative '../test_helper'

class ContentBreadcrumbsBlockTest < ActiveSupport::TestCase

  include NoosferoTestHelper

  def setup
    @block = BreadcrumbsPlugin::ContentBreadcrumbsBlock.new
    @profile = fast_create(Community)
    @folder = fast_create(Folder, :profile_id => @profile.id)
    @article = fast_create(Folder, :profile_id => @profile.id, :parent_id => @folder.id)
    @params = {}
  end

  attr_reader :params

  should 'has a description' do
    assert_not_equal Block.description, BreadcrumbsPlugin::ContentBreadcrumbsBlock.description
  end

  should 'has a help' do
    assert @block.help
  end

  should 'return path of links to reach a page' do
    links = [{:name => @folder.name, :url => @folder.url}, {:name => @article.name, :url => @article.url}]
    assert_equal links, @block.page_trail(@article)
  end

  should 'return path of links when current page is at cms controller' do
    params = {:controller => 'cms', :action => 'edit', :id => @article.id}
    links = [{:name => @folder.name, :url => @folder.url}, {:name => @article.name, :url => @article.url}, {:url=>{:controller=>"cms", :action=>"edit", :id=>@article.id}, :name=>"Edit"}]
    assert_equal links, @block.page_trail(nil, params)
  end

  should 'not return cms action link when show_cms_action is false' do
    params = {:controller => 'cms', :action => 'edit', :id => @article.id}
    links = [{:name => @folder.name, :url => @folder.url}, {:name => @article.name, :url => @article.url}]
    @block.show_cms_action = false
    assert_equal links, @block.page_trail(nil, params)
  end

  should 'include profile page link on path of links to reach a profile controller page' do
    params = {:controller => 'profile', :action => 'members', :profile => @profile.identifier}
    links = [{:name => 'Profile', :url => {:controller => 'profile', :action => 'index', :profile => @profile.identifier}}, {:name => 'Members', :url => {:controller=>'profile', :action=>'members', :profile=> @profile.identifier}}]
    assert_equal links, @block.page_trail(nil, params)
  end

  should 'include only the profile page link on path links when profile action is index' do
    params = {:controller => 'profile', :action => 'index', :profile => @profile.identifier}
    links = [{:name => 'Profile', :url => {:controller => 'profile', :action => 'index', :profile => @profile.identifier}}]
    assert_equal links, @block.page_trail(nil, params)
  end

  should 'profile page be the ancestor page of event profile page calendar' do
    params = {:controller => 'profile', :action => 'events', :profile => @profile.identifier}
    links = [{:name => 'Profile', :url => {:controller => 'profile', :action => 'index', :profile => @profile.identifier}}, {:name => 'Events', :url => {:controller=>'profile', :action=>'events', :profile=> @profile.identifier}}]
    assert_equal links, @block.page_trail(nil, params)
  end

  should 'include profile link on path of links to reach a page' do
    links = [{:name => @profile.name, :url => @profile.url}, {:name => @folder.name, :url => @folder.url}, {:name => @article.name, :url => @article.url}]
    assert_equal links, @block.trail(@article, @profile)
  end

  should 'not include profile link on path of links when show_profile is false' do
    links = [{:name => @folder.name, :url => @folder.url}, {:name => @article.name, :url => @article.url}]
    @block.show_profile = false
    assert_equal links, @block.trail(@article, @profile)
  end

  should 'not include profile link on path of links when trail is empty' do
    assert_equal [], @block.trail(nil, @profile)
  end

  should 'render trail if there is links to show' do
    @page = @article
    trail = instance_eval(&@block.content)
    assert_match /#{@profile.name}/, trail
    assert_match /#{@folder.name}/, trail
    assert_match /#{@page.name}/, trail
  end

  should 'render nothing if there is no links to show' do
    @page = nil
    assert_equal '', instance_eval(&@block.content)
  end

  should 'not be cacheable' do
    refute @block.cacheable?
  end

end
