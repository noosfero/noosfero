require File.dirname(__FILE__) + '/../test_helper'
require 'profile_controller'

# Re-raise errors caught by the controller.
class ProfileController; def rescue_action(e) raise e end; end

class ProfileControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testuser').person
  end
  attr_reader :profile

  def test_local_files_reference
    assert_local_files_reference
  end
  
  def test_valid_xhtml
    assert_valid_xhtml
  end
  
  noosfero_test :profile => 'testuser'

  should 'list friends' do
    get :friends

    assert_response :success
    assert_template 'friends'
    assert_kind_of Array, assigns(:friends)
  end

  should 'point to manage friends in user is seeing his own friends' do
    login_as('testuser')
    get :friends
    assert_tag :tag => 'a', :attributes => { :href => '/myprofile/testuser/friends' }
  end

  should 'not point to manage friends of other users' do
    login_as('ze')
    get :friends
    assert_no_tag :tag => 'a', :attributes => { :href => '/myprofile/testuser/friends' }
  end

  should 'list communities' do
    get :communities

    assert_response :success
    assert_template 'communities'
    assert_kind_of Array, assigns(:communities)
  end

  should 'list enterprises' do
    get :enterprises

    assert_response :success
    assert_template 'enterprises'
    assert_kind_of Array, assigns(:enterprises)
  end

  should 'list members (for organizations)' do
    get :members

    assert_response :success
    assert_template 'members'
    assert_kind_of Array, assigns(:members)
  end
  
  should 'list favorite enterprises' do
    get :favorite_enterprises

    assert_response :success
    assert_template 'favorite_enterprises'
    assert_kind_of Array, assigns(:favorite_enterprises)
  end

  should 'render join template without layout when called with AJAX' do
    community = Community.create!(:name => 'my test community')
    login_as(@profile.identifier)
    @request.expects(:xhr?).returns(true).at_least_once

    get :join, :profile => community.identifier
    assert_response :success
    assert_template 'join'
    assert_no_tag :tag => 'html'
  end

  should 'render join template with layout in general' do
    community = Community.create!(:name => 'my test community')
    login_as(@profile.identifier)
    @request.expects(:xhr?).returns(false).at_least_once

    get :join, :profile => community.identifier
    assert_response :success
    assert_template 'join'
    assert_tag :tag => 'html'
  end

  should 'show Join This Community button for non-member users' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    get :index, :profile => community.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/profile/#{community.identifier}/join" }
  end

  should 'not show Join This Community button for member users' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    community.add_member(@profile)
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{@profile.identifier}/memberships/join/#{community.id}" }

  end

  should 'not show Join This Community button for non-registered users' do
    community = Community.create!(:name => 'my test community')
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{@profile.identifier}/memberships/leave/#{community.id}" }

  end

  should 'not show enterprises link to enterprise' do
    ent = Enterprise.create!(:identifier => 'test_enterprise1', :name => 'Test enteprise1')
    get :index, :profile => ent.identifier
    assert_no_tag :tag => 'a', :content => 'Enterprises', :attributes => { :href => /profile\/#{ent.identifier}\/enterprises$/ }
  end

  should 'not show members link to person' do
    person = create_user('person_1').person
    get :index, :profile => person.identifier
    assert_no_tag :tag => 'a', :content => 'Members', :attributes => { :href => /profile\/#{person.identifier}\/members$/ }
  end

  should 'show friends link to person' do
    person = create_user('person_1').person
    get :index, :profile => person.identifier
    assert_tag :tag => 'a', :content => /#{profile.friends.count}/, :attributes => { :href => /profile\/#{person.identifier}\/friends$/ }
  end

  should 'display tag for profile' do
    @profile.articles.create!(:name => 'testarticle', :tag_list => 'tag1')

    get :tag, :profile => @profile.identifier, :id => 'tag1'
    assert_tag :tag => 'a', :attributes => { :href => /testuser\/testarticle$/ }
  end

  should 'link to the same tag but for whole environment' do
    @profile.articles.create!(:name => 'testarticle', :tag_list => 'tag1')
    get :tag, :profile => @profile.identifier, :id => 'tag1'

    assert_tag :tag => 'a', :attributes => { :href => '/tag/tag1' }, :content => 'See content tagged with "tag1" in the entire site'
  end

  should 'show a link to own control panel' do
    login_as(@profile.identifier)
    get :index, :profile => @profile.identifier
    assert_tag :tag => 'a', :content => 'Control panel'
  end

  should 'show a link to own control panel in my-network-block if is a group' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    community.blocks.each{|i| i.destroy}
    community.boxes[0].blocks << MyNetworkBlock.new
    community.add_admin(@profile)
    get :index, :profile => community.identifier
    assert_tag :tag => 'a', :content => 'Control panel'
  end

  should 'not show a link to others control panel' do
    login_as(@profile.identifier)
    other = create_user('person_1').person
    other.blocks.each{|i| i.destroy}
    other.boxes[0].blocks << ProfileInfoBlock.new
    get :index, :profile => other.identifier
    assert_no_tag :tag => 'ul', :attributes => { :class => 'profile-info-data' }, :descendant => { :tag => 'a', :content => 'Control panel' }
  end

  should 'show a link to control panel if user has profile_editor permission and is a group' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    community.add_admin(@profile)
    get :index, :profile => community.identifier
    assert_tag :tag => 'a', :attributes => { :href => /\/myprofile\/#{@profile.identifier}/ }, :content => 'Control panel'
  end

  should 'show create community in own profile' do
    login_as(@profile.identifier)
    get :communities, :profile => @profile.identifier
    assert_tag :tag => 'a', :child => { :tag => 'span', :content => 'Create a new community' }
  end

  should 'not show create community on profile of other users' do
    login_as(@profile.identifier)
    person = create_user('person_1').person
    get :communities, :profile => person.identifier
    assert_no_tag :tag => 'a', :child => { :tag => 'span', :content => 'Create a new community' }
  end

  should 'not show Leave This Community button for non-member users' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{@profile.identifier}/memberships/leave/#{community.id}" }
  end

  should 'show Leave This Community button for member users' do
    login_as(@profile.identifier)
    community = Community.create!(:name => 'my test community')
    community.add_member(@profile)
    get :index, :profile => community.identifier
    assert_tag :tag => 'a',
      :attributes => { :href => "/profile/#{community.identifier}/leave" }
  end

  should 'not show Leave This Community button for non-registered users' do
    community = Community.create!(:name => 'my test community')
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/myprofile/#{@profile.identifier}/memberships/leave/#{community.id}" }
  end

  should 'check access before displaying profile' do
    Person.any_instance.expects(:display_info_to?).with(anything).returns(false)
    @profile.visible = false
    @profile.save

    get :index, :profile => @profile.identifier
    assert_response 403
  end

  should 'display add friend button' do
    login_as(@profile.identifier)
    friend = create_user_full('friendtestuser').person
    get :index, :profile => friend.identifier
    assert_tag :tag => 'a', :content => 'Add friend'
  end

  should 'not display add friend button if user already request friendship' do
    login_as(@profile.identifier)
    friend = create_user_full('friendtestuser').person
    AddFriend.create!(:person => @profile, :friend => friend)
    get :index, :profile => friend.identifier
    assert_no_tag :tag => 'a', :content => 'Add friend'
  end

  should 'not display add friend button if user already friend' do
    login_as(@profile.identifier)
    friend = create_user_full('friendtestuser').person
    @profile.add_friend(friend)
    @profile.friends.reload
    assert @profile.is_a_friend?(friend)
    get :index, :profile => friend.identifier
    assert_no_tag :tag => 'a', :content => 'Add friend'
  end

  should 'show message for disabled enterprise' do
    login_as(@profile.identifier)
    ent = Enterprise.create!(:name => 'my test enterprise', :identifier => 'my-test-enterprise', :enabled => false)
    get :index, :profile => ent.identifier
    assert_tag :tag => 'div', :attributes => { :id => 'profile-disabled' }, :content => Environment.default.message_for_disabled_enterprise
  end

  should 'not show message for disabled enterprise to non-enterprises' do
    login_as(@profile.identifier)
    @profile.enabled = false; @profile.save!
    get :index, :profile => @profile.identifier
    assert_no_tag :tag => 'div', :attributes => { :id => 'profile-disabled' }, :content => Environment.default.message_for_disabled_enterprise
  end

  should 'not show message for disabled enterprise if there is a block for it' do
    login_as(@profile.identifier)
    ent = Enterprise.create!(:name => 'my test enterprise', :identifier => 'my-test-enterprise', :enabled => false)
    ent.boxes << Box.new
    ent.boxes[0].blocks << DisabledEnterpriseMessageBlock.new
    ent.save
    get :index, :profile => ent.identifier
    assert_no_tag :tag => 'div', :attributes => {:class => 'blocks'}, :descendant => { :tag => 'div', :attributes => { :id => 'profile-disabled' }}
  end

  should 'display "Products" link for enterprise' do
    ent = Enterprise.create!(:name => 'my test enterprise', :identifier => 'my-test-enterprise', :enabled => false)

    get :index, :profile => 'my-test-enterprise'
    assert_tag :tag => 'a', :attributes => { :href => '/catalog/my-test-enterprise'}, :content => /Products\/Services/
  end

  should 'not display "Products" link for enterprise if environment do not let' do
    env = Environment.default
    env.enable('disable_products_for_enterprises')
    env.save!
    ent = Enterprise.create!(:name => 'my test enterprise', :identifier => 'my-test-enterprise', :enabled => false, :environment => env)

    get :index, :profile => 'my-test-enterprise'
    assert_no_tag :tag => 'a', :attributes => { :href => '/catalog/my-test-enterprise'}, :content => /Products\/Services/
  end


  should 'not display "Products" link for people' do
    get :index, :profile => 'ze'
    assert_no_tag :tag => 'a', :attributes => { :href => '/catalog/my-test-enterprise'}, :content => /Products\/Services/
  end

  should 'list top level articles in sitemap' do
    get :sitemap, :profile => 'testuser'
    assert_equal @profile.top_level_articles, assigns(:articles)
  end

  should 'list tags' do
    Person.any_instance.stubs(:article_tags).returns({ 'one' => 1, 'two' => 2})
    get :tags, :profile => 'testuser'

    assert_tag :tag => 'div', :attributes => { :class => /main-block/ }, :descendant => { :tag => 'a', :attributes => { :href => '/profile/testuser/tag/one'} }
    assert_tag :tag => 'div', :attributes => { :class => /main-block/ }, :descendant => { :tag => 'a', :attributes => { :href => '/profile/testuser/tag/two'} }
  end

  should 'show e-mail for friends on profile page' do
    p1 = create_user('tusr1').person
    p2 = create_user('tusr2', :email => 't2@t2.com').person
    p2.add_friend p1
    login_as 'tusr1'

    get :index, :profile => 'tusr2'
    assert_tag :content => /t2.*t2.com/
  end

  should 'not show e-mail for non friends on profile page' do
    p1 = create_user('tusr1').person
    p2 = create_user('tusr2', :email => 't2@t2.com').person
    login_as 'tusr1'

    get :index, :profile => 'tusr2'
    assert_no_tag :content => /t2@t2.com/
  end

  should 'display contact us for enterprises' do
    ent = Enterprise.create!(:name => 'my test enterprise', :identifier => 'my-test-enterprise')
    get :index, :profile => 'my-test-enterprise'
    assert_tag :tag => 'a', :attributes => { :href => "/contact/my-test-enterprise/new" }, :content => 'Contact us'
  end

  should 'not display contact us for non-enterprises' do
    get :index, :profile => @profile.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/contact/#{@profile.identifier}/new" }, :content => 'Contact us'
  end

  should 'display contact us only if enabled' do
    ent = Enterprise.create!(:name => 'my test enterprise', :identifier => 'my-test-enterprise', :enable_contact_us => false)
    get :index, :profile => 'my-test-enterprise'
    assert_no_tag :tag => 'a', :attributes => { :href => "/contact/my-test-enterprise/new" }, :content => 'Contact us'
  end
  
  should 'display contact button only if friends' do
    friend = create_user_full('friend_user').person
    @profile.add_friend(friend)
    env = Environment.default
    env.disable('disable_contact_person')
    env.save!
    login_as(@profile.identifier)
    get :index, :profile => friend.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/contact/#{friend.identifier}/new" }
  end

  should 'not display contact button if no friends' do
    nofriend = create_user_full('no_friend').person
    login_as(@profile.identifier)
    get :index, :profile => nofriend.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/contact/#{nofriend.identifier}/new" }
  end

  should 'display contact button only if friends and its enable in environment' do
    friend = create_user_full('friend_user').person
    env = Environment.default
    env.disable('disable_contact_person')
    env.save!
    @profile.add_friend(friend)
    login_as(@profile.identifier)
    get :index, :profile => friend.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/contact/#{friend.identifier}/new" }
  end

  should 'not display contact button if friends and its disable in environment' do
    friend = create_user_full('friend_user').person
    env = Environment.default
    env.enable('disable_contact_person')
    env.save!
    @profile.add_friend(friend)
    login_as(@profile.identifier)
    get :index, :profile => friend.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/contact/#{friend.identifier}/new" }
  end

  should 'display contact button for community if its enable in environment' do
    env = Environment.default
    community = Community.create!(:name => 'my test community', :environment => env)
    env.disable('disable_contact_community')
    env.save!
    community.add_member(@profile)
    login_as(@profile.identifier)
    get :index, :profile => community.identifier
    assert_tag :tag => 'a', :attributes => { :href => "/contact/#{community.identifier}/new" }
  end

  should 'not display contact button for community if its disable in environment' do
    env = Environment.default
    community = Community.create!(:name => 'my test community', :environment => env)
    env.enable('disable_contact_community')
    env.save!
    community.add_member(@profile)
    login_as(@profile.identifier)
    get :index, :profile => community.identifier
    assert_no_tag :tag => 'a', :attributes => { :href => "/contact/#{community.identifier}/new" }
  end

  should 'present confirmation before joining a profile' do
    community = Community.create!(:name => 'my test community')
    login_as @profile.identifier
    get :join, :profile => community.identifier

    assert_response :success
    assert_template 'join'
  end

  should 'actually join profile' do
    community = Community.create!(:name => 'my test community')
    login_as @profile.identifier
    post :join, :profile => community.identifier, :confirmation => '1'

    assert_response :redirect
    assert_redirected_to community.url

    profile = Profile.find(@profile.id)
    assert profile.memberships.include?(community), 'profile should be actually added to the community'
  end

  should 'join profile from wizard' do
    community = Community.create!(:name => 'my test community')
    login_as @profile.identifier
    post :join, :profile => community.identifier, :confirmation => '1', :wizard => true

    assert_response :redirect
    assert_redirected_to :controller => 'search', :action => 'assets', :asset => 'communities', :wizard => true

    profile = Profile.find(@profile.id)
    assert profile.memberships.include?(community), 'profile should be actually added to the community'
  end

  should 'create task when join to closed organization' do
    community = Community.create!(:name => 'my test community', :closed => true)
    login_as @profile.identifier
    assert_difference AddMember, :count do
      post :join, :profile => community.identifier, :confirmation => '1'
    end
  end

  should 'require login to join community' do
    community = Community.create!(:name => 'my test community', :closed => true)
    get :join, :profile => community.identifier

    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'require login to refuse join community' do
    community = Community.create!(:name => 'my test community', :closed => true)
    get :refuse_join, :profile => community.identifier

    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'register join refusal' do
    community = Community.create!(:name => 'my test community', :closed => true)
    login_as @profile.identifier

    get :refuse_join, :profile => community.identifier

    p = Person.find(@profile.id)
    assert_includes p.refused_communities, community
  end

  should 'register in session join refusal' do
    community = Community.create!(:name => 'my test community')
    get :refuse_for_now, :profile => community.identifier

    assert_not_nil session[:no_asking]
    assert_includes session[:no_asking], community.id
  end

  should 'record only 10 communities in session' do
    @request.session[:no_asking] = (1..10).to_a
    community = Community.create!(:name => 'my test community')
    get :refuse_for_now, :profile => community.identifier

    assert_equal ((2..10).to_a + [community.id]), @request.session[:no_asking]
  end

  should 'present confirmation before leaving a profile' do
    community = Community.create!(:name => 'my test community')
    community.add_member(profile)

    login_as(profile.identifier)
    get :leave, :profile => community.identifier

    assert_template 'leave'
    assert_tag :tag => 'input', :attributes => {:value => 'Yes, I want to leave.', :type => 'submit'}
  end

  should 'actually leave profile' do
    community = Community.create!(:name => 'my test community')
    community.add_member(profile)
    assert_includes profile.memberships, community

    login_as(profile.identifier)
    post :leave, :profile => community.identifier, :confirmation => '1'

    profile = Profile.find(@profile.id)
    assert_not_includes profile.memberships, community
  end

  should 'leave profile when on wizard' do
    community = Community.create!(:name => 'my test community')
    community.add_member(profile)

    login_as(profile.identifier)
    post :leave, :profile => community.identifier, :confirmation => '1', :wizard => true

    assert_response :redirect
    assert_redirected_to :controller => 'search', :action => 'assets', :asset => 'communities', :wizard => true

    profile = Profile.find(@profile.id)
    assert_not_includes profile.memberships, community
  end

  should "offer button to close 'leave community' lightbox" do
    community = Community.create!(:name => 'my test community')
    community.add_member(profile)

    login_as(profile.identifier)
    get :index, :profile => community.identifier

    assert_tag :tag => 'a', :content => 'Leave', :attributes => { :href => "/profile/#{community.identifier}/leave", :class => /^lbOn/ }
  end

  should 'offer button to cancel leaving community' do
    community = Community.create!(:name => 'my test community')
    community.add_member(profile)

    login_as(profile.identifier)
    get :leave, :profile => community.identifier

    assert_tag :tag => 'a', :content => "No, I don't want."
  end

  should 'render without layout when use lightbox to leave community' do
    community = Community.create!(:name => 'my test community')
    community.add_member(profile)

    @request.stubs(:xhr?).returns(true)
    login_as(profile.identifier)
    get :leave, :profile => community.identifier

    assert_no_tag :tag => 'body' # e.g. no layout
  end

  should 'require login to leave community' do
    community = Community.create!(:name => 'my test community')
    get :leave, :profile => community.identifier

    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should 'redirect to stored location after leave community' do
    community = Community.create!(:name => 'my test community')
    community.add_member(profile)

    @request.session[:return_to] = "/profile/#{community.identifier}/to_go"
    login_as(profile.identifier)

    post :leave, :profile => community.identifier, :confirmation => '1'

    assert_redirected_to "/profile/#{community.identifier}/to_go"
  end

  should 'store referer location when request leave via get' do
    community = Community.create!(:name => 'my test community')
    login_as(profile.identifier)

    assert_nil @request.session[:return_to]
    @request.expects(:referer).returns("/profile/redirect_to")

    get :leave, :profile => community.identifier

    assert_equal '/profile/redirect_to', @request.session[:return_to]
  end

  should 'store referer location when request join via get' do
    community = Community.create!(:name => 'my test community')
    login_as(profile.identifier)

    assert_nil @request.session[:return_to]
    @request.expects(:referer).returns("/profile/redirect_to").at_least_once

    get :join, :profile => community.identifier

    assert_equal '/profile/redirect_to', @request.session[:return_to]
  end

  should 'redirect to stored location after join community' do
    community = Community.create!(:name => 'my test community')

    @request.session[:return_to] = "/profile/#{community.identifier}/to_go"
    login_as(profile.identifier)

    post :join, :profile => community.identifier, :confirmation => '1'

    assert_redirected_to "/profile/#{community.identifier}/to_go"
  end

  should 'store location before login when request join via get not logged' do
    community = Community.create!(:name => 'my test community')

    @request.expects(:referer).returns("/profile/#{community.identifier}")

    get :join, :profile => community.identifier

    assert_equal "/profile/#{community.identifier}", @request.session[:before_join]
  end

  should 'redirect to location before login after join community' do
    community = Community.create!(:name => 'my test community')

    @request.session[:return_to] = "/profile/#{community.identifier}/to_go"
    login_as(profile.identifier)

    post :join, :profile => community.identifier, :confirmation => '1'

    assert_redirected_to "/profile/#{community.identifier}/to_go"

    assert_nil @request.session[:before_join]
  end

  should 'show number of published events in index' do
    profile.articles << Event.new(:name => 'Published event', :start_date => Date.today)
    profile.articles << Event.new(:name => 'Unpublished event', :start_date => Date.today, :published => false)

    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :content => '1', :attributes => { :href => "/profile/testuser/events" }
  end

  should 'show number of published posts in index' do
    profile.articles << blog = Blog.create(:name => 'Blog', :profile_id => profile.id)
    blog.posts << TextileArticle.new(:name => 'Published post', :parent => profile.blog, :profile => profile)
    blog.posts << TextileArticle.new(:name => 'Other published post', :parent => profile.blog, :profile => profile)
    blog.posts << TextileArticle.new(:name => 'Unpublished post', :parent => profile.blog, :profile => profile, :published => false)

    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :content => '2 posts', :attributes => { :href => /\/testuser\/blog/ }
  end

  should 'show number of published images in index' do
    folder = Folder.create!(:name => 'gallery', :profile => profile, :view_as => 'image_gallery')
    published_file = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    unpublished_file = UploadedFile.create!(:profile => profile, :parent => folder, :uploaded_data => fixture_file_upload('/files/other-pic.jpg', 'image/jpg'), :published => false)

    get :index, :profile => profile.identifier
    assert_tag :tag => 'a', :content => 'One picture', :attributes => { :href => /\/testuser\/gallery/ }
  end

  should 'show description of orgarnization' do
    login_as(@profile.identifier)
    ent = fast_create(Enterprise)
    ent.description = 'Enterprise\'s description'
    ent.save
    get :index, :profile => ent.identifier
    assert_tag :tag => 'div', :attributes => { :class => 'public-profile-description' }, :content => /Enterprise\'s description/
  end

  should 'show description of person' do
    login_as(@profile.identifier)
    @profile.description = 'Person\'s description'
    @profile.save
    get :index, :profile => @profile.identifier
    assert_tag :tag => 'div', :attributes => { :class => 'public-profile-description' }, :content => /Person\'s description/
  end

  should 'ask for login if user not logged' do
    enterprise = fast_create(Enterprise)
    get :unblock, :profile => enterprise.identifier
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  should ' not allow ordinary users to unblock enterprises' do
    login_as(profile.identifier)
    enterprise = fast_create(Enterprise)
    get :unblock, :profile => enterprise.identifier
    assert_response 403
  end

  should 'allow environment admin to unblock enteprises' do
    login_as(profile.identifier)
    enterprise = fast_create(Enterprise)
    enterprise.environment.add_admin(profile)
    get :unblock, :profile => enterprise.identifier
    assert_response 302
  end

  should 'reverse the order of posts in tag feed' do
    TextileArticle.create!(:name => 'First post', :profile => profile, :tag_list => 'tag1', :published_at => Time.now)
    TextileArticle.create!(:name => 'Second post', :profile => profile, :tag_list => 'tag1', :published_at => Time.now + 1.day)

    get :tag_feed, :profile => profile.identifier, :id => 'tag1'
    assert_match(/Second.*First/, @response.body)
  end

  should 'display the most recent posts in tag feed' do
    start = Time.now - 30.days
    first = TextileArticle.create!(:name => 'First post', :profile => profile, :tag_list => 'tag1', :published_at => start)
    20.times do |i|
      TextileArticle.create!(:name => 'Post #' + i.to_s, :profile => profile, :tag_list => 'tag1', :published_at => start + i.days)
    end
    last = TextileArticle.create!(:name => 'Last post', :profile => profile, :tag_list => 'tag1', :published_at => Time.now)

    get :tag_feed, :profile => profile.identifier, :id => 'tag1'
    assert_no_match(/First post/, @response.body) # First post is older than other 20 posts already
    assert_match(/Last post/, @response.body) # Latest post must come in the feed
  end

end
