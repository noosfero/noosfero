require File.dirname(__FILE__) + '/../test_helper'
require 'cms_controller'

# Re-raise errors caught by the controller.
class CmsController; def rescue_action(e) raise e end; end

class CmsControllerTest < Test::Unit::TestCase

  fixtures :environments

  def setup
    @controller = CmsController.new
    @request    = ActionController::TestRequest.new
    @request.stubs(:ssl?).returns(true)
    @response   = ActionController::TestResponse.new

    @profile = create_user_with_permission('testinguser', 'post_content')
    login_as :testinguser
  end

  attr_reader :profile

  def test_local_files_reference
    assert_local_files_reference :get, :index, :profile => profile.identifier
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  should 'list top level documents on index' do
    get :index, :profile => profile.identifier

    assert_template 'view'
    assert_equal profile, assigns(:profile)
    assert_nil assigns(:article)
    assert_kind_of Array, assigns(:subitems)
  end

  should 'be able to view a particular document' do

    a = profile.articles.build(:name => 'blablabla')
    a.save!
    
    get :view, :profile => profile.identifier, :id => a.id

    assert_template 'view'
    assert_equal a, assigns(:article)
    assert_equal [], assigns(:subitems)

    assert_kind_of Array, assigns(:subitems)
  end

  should 'be able to edit a document' do
    a = profile.articles.build(:name => 'test')
    a.save!

    get :edit, :profile => profile.identifier, :id => a.id
    assert_template 'edit'
  end

  should 'be able to create a new document' do
    get :new, :profile => profile.identifier
    assert_response :success
    assert_template 'select_article_type'

    # TODO add more types here !!
    [ TinyMceArticle, TextileArticle ].each do |item|
      assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/new?type=#{item.name}" }
    end
  end

  should 'present edit screen after choosing article type' do
    get :new, :profile => profile.identifier, :type => 'TinyMceArticle'
    assert_template 'edit'

    assert_tag :tag => 'form', :attributes => { :action => "/myprofile/#{profile.identifier}/cms/new", :method => /post/i }, :descendant => { :tag => "input", :attributes => { :type => 'hidden', :value => 'TinyMceArticle' }}
  end

  should 'be able to save a document' do
    assert_difference Article, :count do
      post :new, :type => 'TinyMceArticle', :profile => profile.identifier, :article => { :name => 'a test article', :body => 'the text of the article ...' }
    end
  end

  should 'display set as home page link to non folder' do
    a = profile.articles.create!(:name => 'my new home page')
    Article.stubs(:short_description).returns('bli')
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :content => 'Use as homepage', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/set_home_page/#{a.id}" }
  end

  should 'display set as home page link to folder' do
    a = Folder.new(:name => 'article folder'); profile.articles << a;  a.save!
    Article.stubs(:short_description).returns('bli')
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :content => 'Use as homepage', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/set_home_page/#{a.id}" }
  end

  should 'be able to set home page' do
    a = profile.articles.build(:name => 'my new home page')
    a.save!
    
    assert_not_equal a, profile.home_page

    post :set_home_page, :profile => profile.identifier, :id => a.id

    assert_redirected_to :action => 'view', :id => a.id

    profile = Profile.find(@profile.id)
    assert_equal a, profile.home_page
  end

  should 'set last_changed_by when creating article' do
    login_as(profile.identifier)

    post :new, :type => 'TinyMceArticle', :profile => profile.identifier, :article => { :name => 'changed by me', :body => 'content ...' }

    a = profile.articles.find_by_path('changed-by-me')
    assert_not_nil a
    assert_equal profile, a.last_changed_by
  end

  should 'set last_changed_by when updating article' do
    other_person = create_user('otherperson').person

    a = profile.articles.build(:name => 'my article')
    a.last_changed_by = other_person
    a.save!
    
    login_as(profile.identifier)
    post :edit, :profile => profile.identifier, :id => a.id, :article => { :body => 'new content for this article' }

    a.reload

    assert_equal profile, a.last_changed_by
  end

  should 'edit by using the correct template to display the editor depending on the mime-type' do
    a = profile.articles.build(:name => 'test document')
    a.save!
    assert_equal 'text/html', a.mime_type

    get :edit, :profile => profile.identifier, :id => a.id
    assert_response :success
    assert_template 'edit'
  end

  should 'convert mime-types to action names' do
    obj = mock
    obj.extend(CmsHelper)

    assert_equal 'text_html', obj.mime_type_to_action_name('text/html')
    assert_equal 'image', obj.mime_type_to_action_name('image')
    assert_equal 'application_xnoosferosomething', obj.mime_type_to_action_name('application/x-noosfero-something')
  end

  should 'be able to remove article' do
    a = profile.articles.build(:name => 'my-article')
    a.save!

    assert_difference Article, :count, -1 do
      post :destroy, :profile => profile.identifier, :id => a.id
      assert_redirected_to :action => 'index'
    end
  end

  should 'be able to create a RSS feed' do
    login_as(profile.identifier)
    assert_difference RssFeed, :count do
      post :new, :type => RssFeed.name, :profile => profile.identifier, :article => { :name => 'new-feed', :limit => 15, :include => 'all', :feed_item_description => 'body' }
      assert_response :redirect
    end
  end

  should 'be able to update a RSS feed' do
    login_as(profile.identifier)
    feed = RssFeed.create!(:name => 'myfeed', :limit => 5, :feed_item_description => 'body', :include => 'all', :profile_id => profile.id)
    post :edit, :profile => profile.identifier, :id => feed.id, :article => { :limit => 77, :feed_item_description => 'abstract', :include => 'parent_and_children' }
    assert_response :redirect

    updated = RssFeed.find(feed.id)
    assert_equal 77, updated.limit
    assert_equal 'abstract', updated.feed_item_description
    assert_equal 'parent_and_children', updated.include
  end

  should 'be able to upload a file' do
    assert_difference UploadedFile, :count do
      post :new, :type => UploadedFile.name, :profile => profile.identifier, :article => { :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain')}
    end
    assert_not_nil profile.articles.find_by_path('test.txt')
    assigns(:article).destroy
  end

  should 'be able to update an uploaded file' do
    post :new, :type => UploadedFile.name, :profile => profile.identifier, :article => { :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain')}

    file = profile.articles.find_by_path('test.txt')
    assert_equal 'test.txt', file.name

    post :edit, :profile => profile.identifier, :id => file.id, :article => { :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain')}

    assert_equal 2, file.versions(true).size
  end

  should 'be able to upload an image' do
    assert_difference UploadedFile, :count do
      post :new, :type => UploadedFile.name, :profile => profile.identifier, :article => { :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')}
    end
  end

   should 'be able to upload more than one file at once' do
    assert_difference UploadedFile, :count, 2 do
      post :upload_files, :profile => profile.identifier, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain'), fixture_file_upload('/files/rails.png', 'text/plain')]
    end
    assert_not_nil profile.articles.find_by_path('test.txt')
    assert_not_nil profile.articles.find_by_path('rails.png')
  end

  should 'upload to rigth folder' do
    f = Folder.new(:name => 'f'); profile.articles << f; f.save!
    post :upload_files, :profile => profile.identifier, :parent_id => f.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    f.reload

    assert_not_nil f.children[0]
    assert_equal 'test.txt', f.children[0].name
  end

  should 'display destination folder of files when uploading file in root folder' do
    get :upload_files, :profile => profile.identifier

    assert_tag :tag => 'h5', :descendant => { :tag => 'code', :content => /\/#{profile.identifier}/ }
  end

  should 'display destination folder of files when uploading file' do
    f = Folder.new(:name => 'f'); profile.articles << f; f.save!
    get :upload_files, :profile => profile.identifier, :parent_id => f.id

    assert_tag :tag => 'h5', :descendant => { :tag => 'code', :content => /\/#{profile.identifier}\/#{f.full_name}/}
  end

  should 'not crash on empty file' do
    assert_nothing_raised do
      post :upload_files, :profile => profile.identifier, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain'), '' ]
    end
    assert_not_nil profile.articles.find_by_path('test.txt')
  end

  should 'redirect to cms after uploading files' do
    post :upload_files, :profile => profile.identifier, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    assert_redirected_to :action => 'index'
  end

  should 'redirect to folder after uploading files' do
    f = Folder.new(:name => 'f'); profile.articles << f; f.save!
    post :upload_files, :profile => profile.identifier, :parent_id => f.id, :uploaded_files => [fixture_file_upload('/files/test.txt', 'text/plain')]
    assert_redirected_to :action => 'view', :id => f.id
  end

  should 'display error message when file has more than max size' do
    UploadedFile.any_instance.stubs(:size).returns(UploadedFile.attachment_options[:max_size] + 1024)
    post :upload_files, :profile => profile.identifier, :uploaded_files => [fixture_file_upload('/files/rails.png', 'image/png')]
    assert assigns(:uploaded_files).first.size > UploadedFile.attachment_options[:max_size]
    assert_tag :tag => 'div', :attributes => { :class => 'errorExplanation', :id => 'errorExplanation' }
  end

  should 'not display error message when file has less than max size' do
    UploadedFile.any_instance.stubs(:size).returns(UploadedFile.attachment_options[:max_size] - 1024)
    post :upload_files, :profile => profile.identifier, :uploaded_files => [fixture_file_upload('/files/rails.png', 'image/png')]
    assert_no_tag :tag => 'div', :attributes => { :class => 'errorExplanation', :id => 'errorExplanation' }
  end

  should 'not redirect when some file has errors' do
    UploadedFile.any_instance.stubs(:size).returns(UploadedFile.attachment_options[:max_size] + 1024)
    post :upload_files, :profile => profile.identifier, :uploaded_files => [fixture_file_upload('/files/rails.png', 'image/png')]
    assert_response :success
    assert_template 'upload_files'
  end

  should 'offer to create children' do
    Article.any_instance.stubs(:allow_children?).returns(true)

    article = Article.new(:name => 'test')
    article.profile = profile
    article.save!

    get :view, :profile => profile.identifier, :id => article.id
    assert_response :success
    assert_template 'view'
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/new?parent_id=#{article.id}"}
  end

  should 'not offer to create children if article does not accept them' do
    Article.any_instance.stubs(:allow_children?).returns(false)

    article = Article.new(:name => 'test')
    article.profile = profile
    article.save!

    get :view, :profile => profile.identifier, :id => article.id
    assert_response :success
    assert_template 'view'
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/new?parent_id=#{article.id}"}
  end

  should 'refuse to create children of non-child articles' do
    Article.any_instance.stubs(:allow_children?).returns(false)

    article = Article.new(:name => 'test')
    article.profile = profile
    article.save!

    assert_no_difference UploadedFile, :count do
      assert_raise ArgumentError do
        post :new, :type => UploadedFile.name, :parent_id => article.id, :profile => profile.identifier, :article => { :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain')}
      end
    end
  end

  should 'display max size of uploaded file' do
    get :upload_files, :profile => profile.identifier
    assert_tag :tag => 'h3', :content => /max size #{UploadedFile.max_size.to_humanreadable}/
  end

  should 'display link for selecting categories' do
    # FIXME
    assert true
    #env = Environment.default
    #top = env.categories.build(:display_in_menu => true, :name => 'Top-Level category'); top.save!
    #c1  = env.categories.build(:display_in_menu => true, :name => "Test category 1", :parent_id => top.id); c1.save!
    #c2  = env.categories.build(:display_in_menu => true, :name => "Test category 2", :parent_id => top.id); c2.save!
    #c3  = env.categories.build(:display_in_menu => true, :name => "Test Category 3", :parent_id => top.id); c3.save!

    #article = Article.new(:name => 'test')
    #article.profile = profile
    #article.save!

    #get :edit, :profile => profile.identifier, :id => article.id

    #[c1,c2,c3].each do |item|
    #  assert_tag :tag => 'a', :attributes => { :id => "select-category-#{item.id}-link" }
    #end
  end

  should 'be able to associate articles with categories' do
    env = Environment.default
    c1 = env.categories.build(:name => "Test category 1"); c1.save!
    c2 = env.categories.build(:name => "Test category 2"); c2.save!
    c3 = env.categories.build(:name => "Test Category 3"); c3.save!
  
    # post is in c1 and c3
    post :new, :type => TextileArticle.name, :profile => profile.identifier, :article => { :name => 'adding-categories-test', :category_ids => [ c1.id, c3.id] }

    saved = profile.articles.find_by_name('adding-categories-test')
    assert_includes saved.categories, c1
    assert_not_includes saved.categories, c2
    assert_includes saved.categories, c3
  end

  should 'not associate articles with category twice' do
    env = Environment.default
    c1 = env.categories.build(:name => "Test category 1"); c1.save!
    c2 = env.categories.build(:name => "Test category 2"); c2.save!
    c3 = env.categories.build(:name => "Test Category 3"); c3.save!
  
    # post is in c1, c3 and c3
    post :new, :type => TextileArticle.name, :profile => profile.identifier, :article => { :name => 'adding-categories-test', :category_ids => [ c1.id, c3.id, c3.id ] }

    saved = profile.articles.find_by_name('adding-categories-test')
    assert_equal [c1, c3], saved.categories
  end
  
  should 'filter html from textile article name' do
    post :new, :type => 'TextileArticle', :profile => profile.identifier, :article => { :name => 'a <strong>test</strong> article', :body => 'the text of the article ...' }
    assert_sanitized assigns(:article).name
  end
  
  should 'filter html from textile article abstract' do
    post :new, :type => 'TextileArticle', :profile => profile.identifier, :article => { :name => 'article', :abstract => '<strong>abstract</strong>', :body => 'the text of the article ...' }
    assert_sanitized assigns(:article).abstract
  end
  
  should 'filter html from textile article body' do
    post :new, :type => 'TextileArticle', :profile => profile.identifier, :article => { :name => 'article', :abstract => 'abstract', :body => 'the <b>text</b> of <a href=#>the</a> article ...' }
    assert_sanitized assigns(:article).body
  end
  
  should 'filter html with white_list from tiny mce article name' do
    post :new, :type => 'TinyMceArticle', :profile => profile.identifier, :article => { :name => "<strong>test</strong>", :body => 'the text of the article ...' }
    assert_equal "<strong>test</strong>", assigns(:article).name
  end
  
  should 'filter html with white_list from tiny mce article abstract' do
    post :new, :type => 'TinyMceArticle', :profile => profile.identifier, :article => { :name => 'article', :abstract => "<script>alert('test')</script> article", :body => 'the text of the article ...' }
    assert_equal " article", assigns(:article).abstract
  end
  
  should 'filter html with white_list from tiny mce article body' do
    post :new, :type => 'TinyMceArticle', :profile => profile.identifier, :article => { :name => 'article', :abstract => 'abstract', :body => "the <script>alert('text')</script> of article ..." }
    assert_equal "the  of article ...", assigns(:article).body
  end
  
  should 'not filter html tags permitted from tiny mce article body' do
    post :new, :type => 'TinyMceArticle', :profile => profile.identifier, :article => { :name => 'article', :abstract => 'abstract', :body => "<b>the</b> <script>alert('text')</script> <strong>of</strong> article ..." }
    assert_equal "<b>the</b>  <strong>of</strong> article ...", assigns(:article).body
  end

  should 'sanitize tags' do
    post :new, :type => 'TextileArticle', :profile => profile.identifier, :article => { :name => 'a test article', :body => 'the text of the article ...', :tag_list => 'tag1, <strong>tag2</strong>' }
    assert_sanitized assigns(:article).tag_list.names.join(', ')
  end

  should 'keep informed parent_id' do
    get :new, :profile => @profile.identifier, :parent_id => profile.home_page.id, :type => 'TextileArticle'
    assert_tag :tag => 'input', :attributes => { :name => 'parent_id', :value => profile.home_page.id }
  end

  should 'list folders at top level' do
    Folder.destroy_all
    f1 = Folder.new(:name => 'f1'); profile.articles << f1;  f1.save!
    f2 = Folder.new(:name => 'f2'); profile.articles << f2;  f2.save!

    get :index, :profile => profile.identifier
    assert_equal [f1, f2], assigns(:folders)
    assert_not_includes assigns(:subitems), f1
    assert_not_includes assigns(:subitems), f2
  end

  should 'list folders inside another folder' do
    parent = Folder.new(:name => 'parent'); profile.articles << parent;  parent.save!
    f1 = Folder.new(:name => 'f1', :parent => parent); profile.articles << f1;  f1.save!
    f2 = Folder.new(:name => 'f2', :parent => parent); profile.articles << f2;  f2.save!

    get :view, :profile => profile.identifier, :id => parent.id
    assert_equal [f1, f2], assigns(:folders)
    assert_not_includes assigns(:subitems), f1
    assert_not_includes assigns(:subitems), f2
  end

  should 'offer to create new top-level folder' do
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/new?type=Folder"}
  end

  should 'offer to create sub-folder' do
    f = Folder.new(:name => 'f'); profile.articles << f; f.save!
    get :view, :profile => profile.identifier, :id => f.id

    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/new?parent_id=#{f.id}&amp;type=Folder" }
  end

  should 'redirect back to index after creating top-level article' do
    post :new, :profile => profile.identifier, :type => 'TextileArticle', :article => { :name => 'test' }
    assert_redirected_to :action => 'index'
  end

  should 'redirect back to folder after creating article inside it' do
    f = Folder.new(:name => 'f'); profile.articles << f; f.save!
    post :new, :profile => profile.identifier, :type => 'TextileArticle', :parent_id => f.id, :article => { :name => 'test' }
    assert_redirected_to :action => 'view', :id => f.id
  end

  should 'redirect back to index after editing top-level article' do
    f = Folder.new(:name => 'f'); profile.articles << f; f.save!
    post :edit, :profile => profile.identifier, :id => f.id
    assert_redirected_to :action => 'index'
  end

  should 'redirect back to folder after editing article inside it' do
    f = Folder.new(:name => 'f'); profile.articles << f; f.save!
    a = TextileArticle.create!(:parent => f, :name => 'test', :profile_id => profile.id)

    post :edit, :profile => profile.identifier, :id => a.id
    assert_redirected_to :action => 'view', :id => f.id
  end

  should 'point back to index when cancelling creation of top-level article' do
    get :new, :profile => profile.identifier, :type => 'Folder'
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms" }, :descendant => { :content => /Cancel/ }
  end

  should 'point back to index when cancelling edition of top-level article' do
    f = Folder.new(:name => 'f'); profile.articles << f; f.save!
    get :edit, :profile => profile.identifier, :id => f.id

    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms" }, :descendant => { :content => /Cancel/ }
  end

  should 'point back to folder when cancelling creation of an article inside it' do
    f = Folder.new(:name => 'f'); profile.articles << f; f.save!
    get :new, :profile => profile.identifier, :type => 'Folder', :parent_id => f.id

    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/view/#{f.id}" }, :descendant => { :content => /Cancel/ }
  end

  should 'point back to folder when cancelling edition of an article inside it' do
    f = Folder.new(:name => 'f'); profile.articles << f; f.save!
    a = TextileArticle.create!(:name => 'test', :parent => f, :profile_id => profile.id)
    get :edit, :profile => profile.identifier, :id => a.id

    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/view/#{f.id}" }, :descendant => { :content => /Cancel/ }
  end

  should 'link to page explaining about categorization' do
    get :edit, :profile => profile.identifier, :id => profile.home_page.id
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/why_categorize" }
  end

  should 'present popup' do
    get :why_categorize, :profile => profile.identifier
    assert_template 'why_categorize'
    assert_no_tag :tag => 'body'
  end

  should 'display OK button on why_categorize popup' do
    get :why_categorize, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :rel => 'deactivate'} # lightbox close button
  end

  should 'display published option' do
    get :edit, :profile => profile.identifier, :id => profile.home_page.id
    assert_tag :tag => 'input', :attributes => { :type => 'checkbox', :name => 'article[published]', :checked => 'checked' }
  end

  should "display properly a non-published articles' status" do
    article = profile.articles.create!(:name => 'test', :published => false)

    get :edit, :profile => profile.identifier, :id => article.id
    assert_tag :tag => 'input', :attributes => { :type => 'checkbox', :name => 'article[published]' }
    assert_no_tag :tag => 'input', :attributes => { :type => 'checkbox', :name => 'article[published]', :checked => 'checked' }
  end

  should 'be able to add image with alignment' do
    post :new, :type => 'TinyMceArticle', :profile => profile.identifier, :article => { :name => 'image-alignment', :body => "the text of the article with image <img src='#' align='right'/> right align..." }
    saved = TinyMceArticle.find_by_name('image-alignment')
    assert_match /<img src="#" align="right" \/>/, saved.body
  end

  should 'not be able to add image with alignment when textile' do
    post :new, :type => 'TextileArticle', :profile => profile.identifier, :article => { :name => 'image-alignment', :body => "the text of the article with image <img src='#' align='right'/> right align..." }
    saved = TextileArticle.find_by_name('image-alignment')
    assert_no_match /align="right"/, saved.body
  end

  should 'be able to create a new event document' do
    get :new, :type => 'Event', :profile => profile.identifier
    assert_response :success
    assert_tag :input, :attributes => { :id => 'article_link' }
  end

  should 'not make enterprise homepage available to person' do
    @controller.stubs(:profile).returns(Person.new)
    assert_not_includes @controller.available_article_types, EnterpriseHomepage
  end

  should 'make enterprise homepage available to enterprises' do
    @controller.stubs(:profile).returns(Enterprise.new)
    assert_includes @controller.available_article_types, EnterpriseHomepage
  end

  should 'update categories' do
    env = Environment.default
    top = env.categories.create!(:display_in_menu => true, :name => 'Top-Level category')
    c1  = env.categories.create!(:display_in_menu => true, :name => "Test category 1", :parent_id => top.id)
    c2  = env.categories.create!(:display_in_menu => true, :name => "Test category 2", :parent_id => top.id)
    get :update_categories, :profile => profile.identifier, :category_id => top.id
    assert_template 'shared/_select_categories'
    assert_equal top, assigns(:current_category)
    assert_equal [c1, c2], assigns(:categories)
  end

  should 'record when coming from public view on edit' do
    article = @profile.articles.create!(:name => 'myarticle')

    @request.expects(:referer).returns('http://colivre.net/testinguser/myarticle')

    get :edit, :profile => 'testinguser', :id => article.id
    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'back_to', :value => 'public_view' }
    assert_tag :tag => 'a', :descendant => { :content => 'Cancel' }, :attributes => { :href => /^https?:\/\/colivre.net\/testinguser\/myarticle/ }
  end

  should 'detect when comming from home page' do
    @request.expects(:referer).returns('http://colivre.net/testinguser')
    get :edit, :profile => 'testinguser', :id => @profile.home_page.id
    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'back_to', :value => 'public_view' }
    assert_tag :tag => 'a', :descendant => { :content => 'Cancel' }, :attributes => { :href => /^https?:\/\/colivre.net\/testinguser\/#{@profile.home_page.slug}$/ }
  end

  should 'go back to public view when saving coming from there' do
    article = @profile.articles.create!(:name => 'myarticle')

    post :edit, :profile => 'testinguser', :id => article.id, :back_to => 'public_view'
    assert_redirected_to article.url
  end

  should 'record as coming from public view when creating article' do
    @request.expects(:referer).returns('http://colivre.net/testinguser/testingusers-home-page')
    get :new, :profile => 'testinguser', :type => 'TextileArticle'
    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'back_to', :value => 'public_view' }
    assert_tag :tag => 'a', :descendant => { :content => 'Cancel' }, :attributes => { :href => 'http://colivre.net/testinguser/testingusers-home-page' }
  end

  should 'go to public view after creating article coming from there' do
    post :new, :profile => 'testinguser', :type => 'TextileArticle', :back_to => 'public_view', :article => { :name => 'new-article-from-public-view' }
    assert_response :redirect
    assert_redirected_to @profile.articles.find_by_name('new-article-from-public-view').url
  end

  should 'keep the back_to hint in unsuccessfull saves' do
    post :new, :profile => 'testinguser', :type => 'TextileArticle', :back_to => 'public_view', :article => { }
    assert_response :success
    assert_tag :tag => "input", :attributes => { :type => 'hidden', :name => 'back_to', :value => 'public_view' }
  end

  should 'create a private article child of private folder' do
    folder = Folder.new(:name => 'my intranet', :public_article => false); profile.articles << folder; folder.save!
    
    post :new, :profile => profile.identifier, :type => 'TextileArticle', :parent_id => folder.id, :article => { :name => 'new-private-article'}
    folder.reload

    assert !assigns(:article).public?
    assert_equal 'new-private-article', folder.children[0].name
    assert !folder.children[0].public?
  end

  should 'load communities for that the user belongs' do
    c = Community.create!(:name => 'test comm', :identifier => 'test_comm')
    c.affiliate(profile, Profile::Roles.all_roles)
    a = profile.articles.create!(:name => 'something intresting', :body => 'ruby on rails')
    
    get :publish, :profile => profile.identifier, :id => a.id

    assert_equal [c], assigns(:groups)
    assert_template 'publish'
  end

  should 'publish the article in the selected community if community is not moderated' do
    c = Community.create!(:name => 'test comm', :identifier => 'test_comm', :moderated_articles => false)
    c.affiliate(profile, Profile::Roles.all_roles)
    a = profile.articles.create!(:name => 'something intresting', :body => 'ruby on rails')
    
    assert_difference PublishedArticle, :count do
      post :publish, :profile => profile.identifier, :id => a.id, :marked_groups => [{:name => 'bli', :group_id => c.id.to_s}]
      assert_equal [{'group' => c, 'name' => 'bli'}], assigns(:marked_groups)
    end
  end
  
  should 'create a task for article approval if community is moderated' do
    c = Community.create!(:name => 'test comm', :identifier => 'test_comm', :moderated_articles => true)
    c.affiliate(profile, Profile::Roles.all_roles)
    a = profile.articles.create!(:name => 'something intresting', :body => 'ruby on rails')
    
    assert_no_difference PublishedArticle, :count do
      assert_difference ApproveArticle, :count do
        assert_difference c.tasks, :count do
          post :publish, :profile => profile.identifier, :id => a.id, :marked_groups => [{:name => 'bli', :group_id => c.id.to_s}]
          assert_equal [{'group' => c, 'name' => 'bli'}], assigns(:marked_groups)
        end
      end
    end
  end

  should 'require ssl in general' do
    @request.expects(:ssl?).returns(false).at_least_once
    get :index, :profile => 'testinguser'
    assert_redirected_to :protocol => 'https://'
  end

  should 'accept ajax connections to new action without ssl' do
    @request.expects(:ssl?).returns(false).at_least_once
    xml_http_request :get, :new, :profile => 'testinguser'
    assert_response :success
  end

  should 'not loose type argument in new action when redirecting to ssl' do
    @request.expects(:ssl?).returns(false).at_least_once
    get :new, :profile => 'testinguser', :type => 'Folder'
    assert_redirected_to :protocol => 'https://', :action => 'new', :type => 'Folder'
  end

  should 'not accept non-ajax connections to new action without ssl' do
    @request.expects(:ssl?).returns(false).at_least_once
    get :new, :profile => 'testinguser'
    assert_redirected_to :protocol => 'https://'
  end

  should 'display categories if environment disable_categories disabled' do
    Environment.any_instance.stubs(:enabled?).with(anything).returns(false)
    a = profile.articles.create!(:name => 'test')
    get :edit, :profile => profile.identifier, :id => a.id
    assert_tag :tag => 'div', :descendant => { :tag => 'h4', :content => 'Categorize your article' }
  end

  should 'not display categories if environment disable_categories enabled' do
    Environment.any_instance.stubs(:enabled?).with(anything).returns(true)
    a = profile.articles.create!(:name => 'test')
    get :edit, :profile => profile.identifier, :id => a.id
    assert_no_tag :tag => 'div', :descendant => { :tag => 'h4', :content => 'Categorize your article' }
  end

  should 'not display input name on create blog' do
    get :new, :profile => profile.identifier, :type => 'Blog'
    assert_no_tag :tag => 'input', :attributes => { :name => 'article[name]', :type => 'text' }
  end

  should 'display posts per page input with default value on edit blog' do
    n = Blog.new.posts_per_page.to_s
    get :new, :profile => profile.identifier, :type => 'Blog'
    assert_tag :tag => 'select', :attributes => { :name => 'article[posts_per_page]' }, :child => { :tag => 'option', :attributes => {:value => n, :selected => 'selected'} }
  end

  should 'not offer to create special article types' do
    get :new, :profile => profile.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/new?type=Blog"}
  end

  should 'offer to edit a blog' do
    profile.articles << Blog.new(:name => 'blog test', :profile => profile)

    profile.articles.reload
    assert profile.has_blog?

    b = profile.blog
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/edit/#{b.id}"}
  end

  should 'not offer to add folder to blog' do
    profile.articles << Blog.new(:name => 'blog test', :profile => profile)

    profile.articles.reload
    assert profile.has_blog?

    get :view, :profile => profile.identifier, :id => profile.blog.id
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/new?parent_id=#{profile.blog.id}&amp;type=Folder"}
  end

  should 'not show feed subitem for blog' do
    profile.articles << Blog.new(:name => 'Blog for test', :profile => profile)

    profile.articles.reload
    assert profile.has_blog?

    get :view, :profile => profile.identifier, :id => profile.blog.id

    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/edit/#{profile.blog.feed.id}" }
  end

  should 'update feed options by edit blog form' do
    profile.articles << Blog.new(:name => 'Blog for test', :profile => profile)
    post :edit, :profile => profile.identifier, :id => profile.blog.id, :article => { :feed => { :limit => 7 } }
    assert_equal 7, profile.blog.feed.limit
  end

  should 'not offer folder to blog articles' do
    @controller.stubs(:profile).returns(Enterprise.new)
    blog = Blog.create!(:name => 'Blog for test', :profile => profile)
    @controller.stubs(:params).returns({ :parent_id => blog.id })

    assert_not_includes @controller.available_article_types, Folder
  end

  should 'not offer rssfeed to blog articles' do
    @controller.stubs(:profile).returns(Enterprise.new)
    blog = Blog.create!(:name => 'Blog for test', :profile => profile)
    @controller.stubs(:params).returns({ :parent_id => blog.id })

    assert_not_includes @controller.available_article_types, RssFeed
  end

  should 'update blog posts_per_page setting' do
    profile.articles << Blog.new(:name => 'Blog for test', :profile => profile)
    post :edit, :profile => profile.identifier, :id => profile.blog.id, :article => { :posts_per_page => 5 }
    profile.blog.reload
    assert_equal 5, profile.blog.posts_per_page
  end

  should 'display input title on create blog' do
    get :new, :profile => profile.identifier, :type => 'Blog'
    assert_tag :tag => 'input', :attributes => { :name => 'article[title]', :type => 'text' }
  end

  should "display 'New article' when create children of folder" do
    a = Folder.new(:name => 'article folder'); profile.articles << a;  a.save!
    Article.stubs(:short_description).returns('bli')
    get :view, :profile => profile.identifier, :id => a
    assert_tag :tag => 'a', :content => 'New article'
  end

  should "display 'New post' when create children of blog" do
    a = Blog.create!(:name => 'blog_for_test', :profile => profile)
    Article.stubs(:short_description).returns('bli')
    get :view, :profile => profile.identifier, :id => a
    assert_tag :tag => 'a', :content => 'New post'
  end

  should 'offer confirmation to remove article' do
    a = profile.articles.create!(:name => 'my-article')
    get :destroy, :profile => profile.identifier, :id => a.id
    assert_response :success
    assert_tag :tag => 'input', :attributes => {:type => 'submit', :value => 'Yes, I want.' }
  end

  should 'display notify comments option' do
    a = profile.articles.create!(:name => 'test')
    get :edit, :profile => profile.identifier, :id => a.id
    assert :tag => 'input', :attributes => {:name => 'article[notify_comments]', :value => 1}
  end

  should 'back to control panel after create blog' do
    assert_difference Blog, :count do
      post :new, :type => Blog.name, :profile => profile.identifier, :article => { :name => 'my-blog' }, :back_to => 'control_panel'
      assert_redirected_to :controller => 'profile_editor', :profile => profile.identifier
    end
  end

  should 'back to control panel after config blog' do
    profile.articles << Blog.new(:name => 'my-blog', :profile => profile)
    post :edit, :profile => profile.identifier, :id => profile.blog.id, :back_to => 'control_panel'
    assert_redirected_to :controller => 'profile_editor', :profile => profile.identifier
  end

  should 'back to control panel if cancel create blog' do
    get :new, :profile => profile.identifier, :type => Blog.name
    assert_tag :tag => 'a', :content => 'Cancel', :attributes => { :href => /\/myprofile\/#{profile.identifier}/ }
  end

  should 'back to control panel if cancel config blog' do
    profile.articles << Blog.new(:name => 'my-blog', :profile => profile)
    get :edit, :profile => profile.identifier, :id => profile.blog.id
    assert_tag :tag => 'a', :content => 'Cancel', :attributes => { :href => /\/myprofile\/#{profile.identifier}/ }
  end

  should 'create icon upload file in folder' do
    f = Folder.create!(:name => 'test_folder', :profile => profile, :view_as => 'image_gallery')
    post :new, :profile => profile.identifier,
               :type => UploadedFile.name,
               :parent_id => f.id,
               :article => {:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')}

    assert File.exists?(assigns(:article).icon_name)
    assigns(:article).destroy
  end

  should 'create icon upload file' do
    post :new, :profile => profile.identifier,
               :type => UploadedFile.name,
               :article => {:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png')}

    assert File.exists?(assigns(:article).icon_name)
    assigns(:article).destroy
  end

  should 'record when coming from public view on upload files' do
    folder = Folder.create!(:name => 'testfolder', :profile => profile)

    @request.expects(:referer).returns("http://colivre.net/#{profile.identifier}/#{folder.slug}")

    get :upload_files, :profile => profile.identifier, :parent_id => folder.id
    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'back_to', :value => 'public_view' }
    assert_tag :tag => 'a', :descendant => { :content => 'Cancel' }, :attributes => { :href => /^https?:\/\/colivre.net\/#{profile.identifier}\/#{folder.slug}/ }
  end

  should 'detect when comming from home page to upload files' do
    folder = Folder.create!(:name => 'testfolder', :profile => profile)
    profile.expects(:home_page).returns(folder).at_least_once

    @request.expects(:referer).returns("http://colivre.net/#{profile.identifier}").at_least_once
    @controller.stubs(:profile).returns(profile)
    get :upload_files, :profile => profile.identifier, :parent_id => folder.id
    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'back_to', :value => 'public_view' }
    assert_tag :tag => 'a', :descendant => { :content => 'Cancel' }, :attributes => { :href => /^https?:\/\/colivre.net\/#{profile.identifier}\/#{profile.home_page.slug}$/ }
  end

  should 'go back to public view when upload files coming from there' do
    folder = Folder.create!(:name => 'test_folder', :profile => profile)

    post :upload_files, :profile => profile.identifier, :parent_id => folder.id, :back_to => 'public_view', :uploaded_files => [fixture_file_upload('files/rails.png', 'image/png')]
    assert_template nil
    assert_redirected_to folder.url
  end

  should 'record when coming from public view on edit files with view true' do
    file = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    @request.expects(:referer).returns("http://colivre.net/#{profile.identifier}/#{file.slug}?view=true").at_least_once

    get :edit, :profile => profile.identifier, :id => file.id
    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'back_to', :value => 'public_view' }
    assert_tag :tag => 'a', :descendant => { :content => 'Cancel' }, :attributes => { :href => /^https?:\/\/colivre.net\/#{profile.identifier}\/#{file.slug}?.*view=true/ }
  end

  should 'detect when comming from home page to edit files with view true' do
    file = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    profile.expects(:home_page).returns(file).at_least_once

    @request.expects(:referer).returns("http://colivre.net/#{profile.identifier}?view=true").at_least_once
    @controller.stubs(:profile).returns(profile)
    get :edit, :profile => profile.identifier, :id => file.id
    assert_tag :tag => 'input', :attributes => { :type => 'hidden', :name => 'back_to', :value => 'public_view' }
    assert_tag :tag => 'a', :descendant => { :content => 'Cancel' }, :attributes => { :href => /^https?:\/\/colivre.net\/#{profile.identifier}\/#{profile.home_page.slug}?.*view=true$/ }
  end

  should 'go back to public view when edit files coming from there with view true' do
    file = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    @request.expects(:referer).returns("http://colivre.net/#{profile.identifier}/#{file.slug}?view=true").at_least_once

    post :edit, :profile => profile.identifier, :id => file.id, :back_to => 'public_view', :article => {:abstract => 'some description'}
    assert_template nil
    assert_redirected_to file.url.merge(:view => true)
  end

  should 'display external feed options when edit blog' do
    get :new, :profile => profile.identifier, :type => 'Blog'
    assert_tag :tag => 'input', :attributes => { :name => 'article[external_feed_builder][enabled]' }
    assert_tag :tag => 'input', :attributes => { :name => 'article[external_feed_builder][address]' }
  end

  should "display 'Fetch posts from an external feed' checked if blog has enabled external feed" do
    profile.articles << Blog.new(:title => 'test blog', :profile => profile)
    profile.blog.create_external_feed(:address => 'address', :enabled => true)
    get :edit, :profile => profile.identifier, :id => profile.blog.id
    assert_tag :tag => 'input', :attributes => { :name => 'article[external_feed_builder][enabled]', :checked => 'checked' }
  end

  should "display 'Fetch posts from an external feed' unchecked if blog has disabled external feed" do
    profile.articles << Blog.new(:title => 'test blog', :profile => profile)
    profile.blog.create_external_feed(:address => 'address', :enabled => false)
    get :edit, :profile => profile.identifier, :id => profile.blog.id
    assert_tag :tag => 'input', :attributes => { :name => 'article[external_feed_builder][enabled]', :checked => nil }
  end

  should "hide external feed options when 'Fetch posts from an external feed' unchecked" do
    get :new, :profile => profile.identifier, :type => 'Blog'
    assert_tag :tag => 'input', :attributes => { :name => 'article[external_feed_builder][enabled]', :checked => nil }
    assert_tag :tag => 'div', :attributes => { :id => 'external-feed-options', :style => 'display: none' }
  end

  should 'only_once option marked by default' do
    get :new, :profile => profile.identifier, :type => 'Blog'
    assert_tag :tag => 'input', :attributes => { :name => 'article[external_feed_builder][only_once]', :checked => 'checked', :value => 'true' }
  end

  should 'display iframe for media listing when it is TinyMceArticle and enabled on environment' do
    e = Environment.default
    e.enable('media_panel')
    e.save!

    image_folder = Folder.create(:profile => profile, :name => 'Image folder')
    non_image_folder = Folder.create(:profile => profile, :name => 'Non image folder')

    image = UploadedFile.create!(:profile => profile, :parent => image_folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file = UploadedFile.create!(:profile => profile, :parent => non_image_folder, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))

    get :new, :profile => profile.identifier, :type => 'TinyMceArticle'
    assert_tag :tag => 'iframe', :attributes => { :src => "/myprofile/#{profile.identifier}/cms/media_listing?type=TinyMceArticle" }
  end

  should 'not display iframe for media listing when it is Folder' do
    image_folder = Folder.create(:profile => profile, :name => 'Image folder')
    non_image_folder = Folder.create(:profile => profile, :name => 'Non image folder')

    image = UploadedFile.create!(:profile => profile, :parent => image_folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file = UploadedFile.create!(:profile => profile, :parent => non_image_folder, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))

    get :new, :profile => profile.identifier, :type => 'Folder'
    assert_no_tag :tag => 'iframe', :attributes => { :src => "/myprofile/#{profile.identifier}/cms/media_listing" }
  end

  should 'display list of images' do
    file = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    get :media_listing, :profile => profile.identifier
    assert_tag :tag => 'div', :attributes => { :id => 'media-listing-images' }, :descendant => { :tag => 'img', :attributes => {:src => /#{file.name}/}}
  end

  should 'display list of documents' do
    file = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    get :media_listing, :profile => profile.identifier
    assert_tag :tag => 'div', :attributes => { :id => 'media-listing-documents' }, :descendant => { :tag => 'a', :attributes => {:href => /#{file.name}/}}
  end

  should 'list image folders to select' do
    image_folder = Folder.create(:profile => profile, :name => 'Image folder')
    non_image_folder = Folder.create(:profile => profile, :name => 'Non image folder')

    image = UploadedFile.create!(:profile => profile, :parent => image_folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file = UploadedFile.create!(:profile => profile, :parent => non_image_folder, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))

    get :media_listing, :profile => profile.identifier
    assert_tag :tag => 'div', :attributes => { :id => 'media-listing-images' }, :descendant => { :tag => 'option', :content => /#{image_folder.name}/, :attributes => { :value => image_folder.id}}
    assert_no_tag :tag => 'div', :attributes => { :id => 'media-listing-images' }, :descendant => { :tag => 'option', :content => /#{non_image_folder.name}/, :attributes => { :value => non_image_folder.id}}
  end

  should 'list documents folders to select' do
    image_folder = Folder.create(:profile => profile, :name => 'Image folder')
    non_image_folder = Folder.create(:profile => profile, :name => 'Non image folder')

    image = UploadedFile.create!(:profile => profile, :parent => image_folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file = UploadedFile.create!(:profile => profile, :parent => non_image_folder, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))

    get :media_listing, :profile => profile.identifier
    assert_no_tag :tag => 'div', :attributes => { :id => 'media-listing-documents' }, :descendant => { :tag => 'option', :content => /#{image_folder.name}/, :attributes => { :value => image_folder.id}}
    assert_tag :tag => 'div', :attributes => { :id => 'media-listing-documents' }, :descendant => { :tag => 'option', :content => /#{non_image_folder.name}/, :attributes => { :value => non_image_folder.id}}
  end

  should 'get a list of images from a image folder' do
    folder = Folder.create(:profile => profile, :name => 'Image folder')
    other_folder = Folder.create(:profile => profile, :name => 'Non image folder')
    image = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file_in_folder = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    image_in_other_folder = UploadedFile.create!(:profile => profile, :parent => other_folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    get :media_listing, :profile => profile.identifier, :image_folder_id => folder.id, :format => 'js'

    assert_includes assigns(:images), image
    assert_not_includes assigns(:images), file_in_folder
    assert_not_includes assigns(:images), image_in_other_folder
  end

  should 'get a list of images from profile' do
    image = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    folder = Folder.create(:profile => profile, :name => 'Image folder')
    image_in_folder = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    get :media_listing, :profile => profile.identifier, :image_folder_id => '', :format => 'js'

    assert_includes assigns(:images), image
    assert_not_includes assigns(:images), image_in_folder
  end

  should 'get a list of documents from a document folder' do
    folder = Folder.create(:profile => profile, :name => 'Non images folder')
    other_folder = Folder.create(:profile => profile, :name => 'Image folder')
    file = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    image = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    file_in_other_folder = UploadedFile.create!(:profile => profile, :parent => other_folder, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))

    get :media_listing, :profile => profile.identifier, :document_folder_id => folder.id, :format => 'js'

    assert_includes assigns(:documents), file
    assert_not_includes assigns(:documents), image
    assert_not_includes assigns(:documents), file_in_other_folder
  end

  should 'get a list of documents from profile' do
    file = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))
    folder = Folder.create(:profile => profile, :name => 'Image folder')
    file_in_folder = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))

    get :media_listing, :profile => profile.identifier, :document_folder_id => '', :format => 'js'

    assert_includes assigns(:documents), file
    assert_not_includes assigns(:documents), file_in_folder
  end

  should 'display pagination links of images' do
    @controller.stubs(:per_page).returns(1)
    fixture_filename = '/files/other-pic.jpg'
    filename = RAILS_ROOT + '/test/fixtures' + fixture_filename
    system('echo "image for test" | convert -background yellow -page 32x32 text:- %s' % filename)
    image = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload(fixture_filename, 'image/jpg'))

    image2 = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    get :media_listing, :profile => profile.identifier

    assert_includes assigns(:images), image
    assert_not_includes assigns(:images), image2

    File.rm_f(filename)
  end

  should 'display pagination links of documents' do
    @controller.stubs(:per_page).returns(1)
    file = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/feed.xml', 'text/xml'))
    file2 = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'))

    get :media_listing, :profile => profile.identifier

    assert_includes assigns(:documents), file
    assert_not_includes assigns(:documents), file2
  end


  should 'redirect to media listing when upload files from there' do
    post :upload_files, :profile => profile.identifier, :back_to => 'media_listing', :uploaded_files => [fixture_file_upload('files/rails.png', 'image/png')]
    assert_template nil
    assert_redirected_to :action => 'media_listing'
  end

  should 'redirect to media listing when occur errors when upload files from there' do
    file = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('files/rails.png', 'image/png'))

    post :upload_files, :profile => profile.identifier, :back_to => 'media_listing', :uploaded_files => [fixture_file_upload('files/rails.png', 'image/png')]
    assert_template nil
    assert_redirected_to :action => 'media_listing'
  end

  should "display 'Publish' when profile is a person" do
    a = profile.articles.create!(:name => 'my new home page')
    Article.stubs(:short_description).returns('bli')
    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :attributes => {:href => "/myprofile/#{profile.identifier}/cms/publish/#{a.id}"}
  end

  should "not display 'Publish' when profile is not a person" do
    p = Community.create!(:name => 'community-test')
    p.add_admin(profile)
    a = p.articles.create!(:name => 'my new home page')
    Article.stubs(:short_description).returns('bli')
    get :index, :profile => p.identifier
    assert_no_tag :tag => 'a', :attributes => {:href => "/myprofile/#{p.identifier}/cms/publish/#{a.id}"}
  end
end
