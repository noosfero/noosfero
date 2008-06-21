require File.dirname(__FILE__) + '/../test_helper'
require 'cms_controller'

# Re-raise errors caught by the controller.
class CmsController; def rescue_action(e) raise e end; end

class CmsControllerTest < Test::Unit::TestCase

  fixtures :environments

  def setup
    @controller = CmsController.new
    @request    = ActionController::TestRequest.new
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

  should 'not display set as home page link to folder' do
    a = Folder.new(:name => 'article folder'); profile.articles << a;  a.save!
    Article.stubs(:short_description).returns('bli')
    get :index, :profile => profile.identifier
    assert_no_tag :tag => 'a', :content => 'Use as homepage', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/set_home_page/#{a.id}" }
  end

  should 'be able to set home page' do
    a = profile.articles.build(:name => 'my new home page')
    a.save!
    
    assert_not_equal a, profile.home_page

    post :set_home_page, :profile => profile.identifier, :id => a.id

    assert_redirected_to :action => 'view', :id => a.id

    profile.reload
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
    get :new, :type => UploadedFile.name, :profile => profile.identifier
    assert_tag :tag => 'label', :attributes => { :for => 'article_uploaded_data' }, :content => /max size #{UploadedFile.max_size.to_humanreadable}/
  end

  should 'display checkboxes for selecting categories' do
    env = Environment.default
    top = env.categories.build(:display_in_menu => true, :name => 'Top-Level category'); top.save!
    c1  = env.categories.build(:display_in_menu => true, :name => "Test category 1", :parent_id => top.id); c1.save!
    c2  = env.categories.build(:display_in_menu => true, :name => "Test category 2", :parent_id => top.id); c2.save!
    c3  = env.categories.build(:display_in_menu => true, :name => "Test Category 3", :parent_id => top.id); c3.save!

    article = Article.new(:name => 'test')
    article.profile = profile
    article.save!

    get :edit, :profile => profile.identifier, :id => article.id

    [c1,c2,c3].each do |item|
      assert_tag :tag => 'input', :attributes => { :name => 'article[category_ids][]', :value => item.id}
    end
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

  should 'has tiny mce language pack for avaliable locales' do
    Noosfero.locales.each do |code,name|
      assert File.exists?( RAILS_ROOT.to_s() +'/public/javascripts/tiny_mce/langs/' + code.downcase + '.js' ), "Not found TinyMce language pack for #{name}"
    end
  end

  should 'be able to create a new event document' do
    get :new, :type => 'Event', :profile => profile.identifier
    assert_response :success
    #assert_template 'select_article_type'

    ## TODO add more types here !!
    #[ TinyMceArticle, TextileArticle ].each do |item|
    #  assert_tag :tag => 'a', :attributes => { :href => "/myprofile/#{profile.identifier}/cms/new?type=#{item.name}" }
    #end
  end

end
