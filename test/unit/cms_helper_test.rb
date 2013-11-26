require File.dirname(__FILE__) + '/../test_helper'

class CmsHelperTest < ActiveSupport::TestCase

  include CmsHelper
  include BlogHelper
  include ApplicationHelper
  include ActionView::Helpers::UrlHelper

  should 'show default options for article' do
    CmsHelperTest.any_instance.stubs(:controller).returns(ActionController::Base.new)
    result = options_for_article(RssFeed.new(:profile => Profile.new))
    assert_match /id="article_published_true" name="article\[published\]" type="radio" value="true"/, result
    assert_match /id="article_published_false" name="article\[published\]" type="radio" value="false"/, result
    assert_match /id="article_accept_comments" name="article\[accept_comments\]" type="checkbox" value="1"/, result
  end

  should 'show custom options for blog' do
    CmsHelperTest.any_instance.stubs(:controller).returns(ActionController::Base.new)
    result = options_for_article(Blog.new)
    assert_tag_in_string result, :tag => 'input', :attributes => { :name => 'article[published]' , :type => "hidden", :value => "1" }
    assert_tag_in_string result, :tag => 'input', :attributes => { :name => "article[accept_comments]", :type => "hidden", :value => "0" }
  end

  should 'display link to folder content if article is folder' do
    profile = fast_create(Profile)
    folder = fast_create(Folder, :name => 'My folder', :profile_id => profile.id)
    expects(:link_to).with('My folder', {:action => 'view', :id => folder.id}, :class => icon_for_article(folder))

    result = link_to_article(folder)
  end

  should 'display link to article if article is not folder' do
    profile = fast_create(Profile)
    article = fast_create(TinyMceArticle, :name => 'My article', :profile_id => profile.id)
    expects(:link_to).with('My article', article.url, :class => icon_for_article(article))

    result = link_to_article(article)
  end

  should 'display image and link if article is an image' do
    profile = fast_create(Profile)
    file = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file = FilePresenter.for file
    icon = icon_for_article(file)
    expects(:image_tag).with(icon).returns('icon')

    expects(:link_to).with('rails.png', file.url).returns('link')
    result = link_to_article(file)
  end

  should 'display spread button when profile is a person' do
    @controller = ApplicationController.new
    @plugins.stubs(:dispatch).returns([])
    profile = fast_create(Person)
    article = fast_create(TinyMceArticle, :name => 'My article', :profile_id => profile.id)
    expects(:link_to).with('Spread this', {:action => 'publish', :id => article.id}, :class => 'button with-text icon-spread', :title => nil)

    result = display_spread_button(profile, article)
  end

  should 'display spread button when profile is a community and env has portal_community' do
    @controller = ApplicationController.new
    @plugins.stubs(:dispatch).returns([])
    env = fast_create(Environment)
    env.expects(:portal_community).returns(true)
    profile = fast_create(Community, :environment_id => env.id)
    expects(:environment).returns(env)

    article = fast_create(TinyMceArticle, :name => 'My article', :profile_id => profile.id)

    expects(:link_to).with('Spread this', {:action => 'publish_on_portal_community', :id => article.id}, :class => 'button with-text icon-spread', :title => nil)

    result = display_spread_button(profile, article)
  end

  should 'not display spread button when profile is a community and env has not portal_community' do
    @controller = ApplicationController.new
    @plugins.stubs(:dispatch).returns([])
    env = fast_create(Environment)
    env.expects(:portal_community).returns(nil)
    profile = fast_create(Community, :environment_id => env.id)
    expects(:environment).returns(env)

    article = fast_create(TinyMceArticle, :name => 'My article', :profile_id => profile.id)

    expects(:link_to).with('Spread this', {:action => 'publish_on_portal_community', :id => article.id}, :class => 'button with-text icon-spread', :title => nil).never

    result = display_spread_button(profile, article)
  end

  should 'display delete_button to folder' do
    @controller = ApplicationController.new
    @plugins.stubs(:dispatch).returns([])
    profile = fast_create(Profile)
    name = 'My folder'
    folder = fast_create(Folder, :name => name, :profile_id => profile.id)
    confirm_message = "Are you sure that you want to remove the folder \"#{name}\"? Note that all the items inside it will also be removed!"
    expects(:link_to).with('Delete', {:action => 'destroy', :id => folder.id}, :method => :post, :confirm => confirm_message, :class => 'button with-text icon-delete', :title => nil)

    result = display_delete_button(folder)
  end

  should 'display delete_button to article' do
    @controller = ApplicationController.new
    @plugins.stubs(:dispatch).returns([])
    profile = fast_create(Profile)
    name = 'My article'
    article = fast_create(TinyMceArticle, :name => name, :profile_id => profile.id)
    confirm_message = "Are you sure that you want to remove the item \"#{name}\"?"
    expects(:link_to).with('Delete', {:action => 'destroy', :id => article.id}, :method => :post, :confirm => confirm_message, :class => 'button with-text icon-delete', :title => nil)

    result = display_delete_button(article)
  end
end

module RssFeedHelper
end
