require_relative "../test_helper"

class FolderHelperTest < ActionView::TestCase

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::AssetTagHelper
  include DatesHelper

  include FolderHelper

  should 'display icon for articles' do
    art1 = mock; art1_class = mock
    art1.expects(:class).returns(art1_class)
    art1_class.expects(:icon_name).returns('icon1')

    art2 = mock; art2_class = mock
    art2.expects(:class).returns(art2_class)
    art2_class.expects(:icon_name).returns('icon2')

    assert_equal 'icon icon-icon1', icon_for_article(art1)
    assert_equal 'icon icon-icon2', icon_for_article(art2)
  end

  should 'display icon for images' do
    profile = fast_create(Profile)
    file = create(UploadedFile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'), :profile => profile)
    file = FilePresenter.for file
    process_delayed_job_queue

    assert_match /rails_icon\.png/, icon_for_article(file.reload)
  end

  should 'display icon for type of article' do
    Article.expects(:icon_name).returns('article')
    assert_match /icon-newarticle/, icon_for_new_article(Article)
  end

  should 'list all the folder\'s children to the owner' do
    profile = create_user('Folder Owner').person
    folder = fast_create(Folder, :profile_id => profile.id)
    sub_folder = fast_create(Folder, {:parent_id => folder.id, :profile_id => profile.id})
    sub_blog = fast_create(Blog, {:parent_id => folder.id, :profile_id => profile.id})
    sub_article = fast_create(Article, {:parent_id => folder.id, :profile_id => profile.id, :published => false})

    result = available_articles(folder.children, profile)

    assert_includes result, sub_folder
    assert_includes result, sub_article
    assert_includes result, sub_blog
  end

  should 'list the folder\'s children that are public to the user' do
    profile = create_user('Folder Owner').person
    profile2 = create_user('Folder Viwer').person
    folder = fast_create(Folder, :profile_id => profile.id)
    public_article = fast_create(Article, {:parent_id => folder.id, :profile_id => profile.id, :published => true})
    not_public_article = fast_create(Article, {:parent_id => folder.id, :profile_id => profile.id, :published => false})

    result = available_articles(folder.children, profile2)

    assert_includes result, public_article
    assert_not_includes result, not_public_article
  end

  should ' not list the folder\'s children to the user because the owner\'s profile is not public' do
    profile = create_user('folder-owner').person
    profile.public_profile = false
    profile.save!
    profile2 = create_user('Folder Viwer').person
    folder = fast_create(Folder, :profile_id => profile.id, :published => false)
    article = fast_create(Article, {:parent_id => folder.id, :profile_id => profile.id})

    result = available_articles(folder.children, profile2)

    assert_not_includes result, article
  end

  should ' not list the folder\'s children to the user because the owner\'s profile is not visible' do
    profile = create_user('folder-owner').person
    profile.visible = false
    profile.save!
    profile2 = create_user('Folder Viwer').person
    folder = fast_create(Folder, :profile_id => profile.id)
    article = fast_create(Article, {:parent_id => folder.id, :profile_id => profile.id})

    result = available_articles(folder.children, profile2)

    assert_not_includes result, article
  end

  should 'display the proper content icon' do
    profile = create_user('folder-owner').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id})
    article1 = fast_create(Article, {:name => 'Article1', :parent_id => folder.id, :profile_id => profile.id, :updated_at => DateTime.now })
    article2 = fast_create(Article, {:name => 'Article2', :parent_id => folder.id, :profile_id => profile.id, :updated_at => DateTime.now })

    assert_tag_in_string display_content_icon(article1), :tag => 'a', :attributes => { :href => /.*\/folder-owner\/my-article-[0-9]*(\?|$)/ }
    assert_tag_in_string display_content_icon(article2), :tag => 'a', :attributes => { :href => /.*\/folder-owner\/my-article-[0-9]*(\?|$)/ }
  end

  should 'explictly advise if empty' do
    profile = create_user('folder-owner').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id})
    result = render 'content_viewer/folder', binding

    assert_match '(empty folder)', result
  end

  should 'show body (folder description)' do
    profile = create_user('folder-owner').person
    folder = fast_create(Folder, {:name => 'Parent Folder', :profile_id => profile.id, :body => "This is the folder description"})
    result = render 'content_viewer/folder', binding
    assert_match 'This is the folder description', result
  end


  private
  def render(template, the_binding)
    ERB.new(File.read(Rails.root.join('app/views', template + '.html.erb'))).result(the_binding)
  end

end
