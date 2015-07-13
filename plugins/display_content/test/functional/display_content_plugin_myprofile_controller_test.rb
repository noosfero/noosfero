require_relative '../test_helper'
require_relative '../../controllers/display_content_plugin_myprofile_controller'

class DisplayContentPluginMyprofileControllerTest < ActionController::TestCase

  def setup
    @controller = DisplayContentPluginMyprofileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    user = create_user('testinguser')
    login_as(user.login)
    @profile = user.person
    @environment = @profile.environment

    @environment.enabled_plugins = ['DisplaContentPlugin']
    @environment.save!

#    box = Box.new(:owner => @environment, :position => 1)
#    box.save

    DisplayContentBlock.delete_all
    @block = DisplayContentBlock.new
    @block.box = @profile.boxes.first
    @block.save!
  end

  attr_accessor :profile, :block

  should 'access index action' do
    get :index, :block_id => block.id, :profile => profile.identifier
    json_response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
  end

  should 'index action returns a empty json if there is no content' do
    Article.delete_all
    get :index, :block_id => block.id, :profile => profile.identifier
    json_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal [], json_response
  end

  should 'index action returns an json with node content' do
    Article.delete_all
    article = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)

    get :index, :block_id => block.id, :profile => profile.identifier
    json_response = ActiveSupport::JSON.decode(@response.body)
    expected_json = {'data' => article.title}
    expected_json['attr'] = { 'node_id' => article.id, 'parent_id' => article.parent_id}

    assert_hash_equivalent [expected_json], json_response
  end

  should 'index action returns an json with node checked if the node is in the nodes list' do
    Article.delete_all
    article = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id)
    block.nodes= [article.id]
    block.save!

    get :index, :block_id => block.id, :profile => profile.identifier
    json_response = ActiveSupport::JSON.decode(@response.body)
    expected_json = {'data' => article.title}
    expected_json['attr'] = { 'node_id' => article.id, 'parent_id' => article.parent_id}
    expected_json['attr'].merge!({'class' => 'jstree-checked'})

    assert_hash_equivalent [expected_json], json_response
  end

  should 'index action returns an json with node undetermined if the node is in the parent nodes list' do
    Article.delete_all
    f = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    article = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => f.id)
    article2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id, :parent_id => f.id)
    block.nodes = [article.id]
    block.save!

    get :index, :block_id => block.id, :profile => profile.identifier
    json_response = ActiveSupport::JSON.decode(@response.body)
    expected_json = { 'node_id' => f.id, 'class' => 'jstree-undetermined', 'parent_id' => f.parent_id}
    assert_equal expected_json, json_response.first['attr']
  end

  should 'index action returns an json with node closed if the node has article with children' do
    Article.delete_all
    f = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    article = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => f.id)
    block.save!

    get :index, :block_id => block.id, :profile => profile.identifier
    json_response = ActiveSupport::JSON.decode(@response.body)
    expected_json = {'data' => f.title}
    expected_json['attr'] = { 'node_id' => f.id, 'parent_id' => f.parent_id}
    expected_json['state'] = 'closed'

    assert_hash_equivalent [expected_json], json_response
  end

  should 'index action returns an json with all the children nodes if some parent is in the parents list' do
    Article.delete_all
    f = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => f.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id, :parent_id => f.id)
    block.checked_nodes = {a1.id => true}
    block.save!

    get :index, :block_id => block.id, :profile => profile.identifier
    json_response = ActiveSupport::JSON.decode(@response.body)
    expected_json = {'data' => f.title}
    expected_json['attr'] = { 'node_id' => f.id, 'parent_id' => f.parent_id}
    children = [
      {'data' => a1.title, 'attr' => {'node_id' => a1.id, 'parent_id' => a1.parent_id, "class" => "jstree-checked"}},
      {'data' => a2.title, 'attr' => {'node_id' => a2.id, 'parent_id'=> a2.parent_id}}
    ]
    expected_json['attr'].merge!({'class' => 'jstree-undetermined'})
    expected_json['children'] = children
    expected_json['state'] = 'closed'

    assert_hash_equivalent [expected_json], json_response
  end

  should 'index action returns an json with all the children nodes and root nodes if some parent is in the parents list and there is others root articles' do
    Article.delete_all
    f = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => f.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id, :parent_id => f.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id)
    block.checked_nodes = {a1.id => true}
    block.save!

    get :index, :block_id => block.id, :profile => profile.identifier
    json_response = ActiveSupport::JSON.decode(@response.body)
    expected_json = []
    value = {'data' => f.title}
    value['attr'] = { 'node_id' => f.id, 'parent_id' => f.parent_id}
    children = [
      {'data' => a1.title, 'attr' => {'node_id' => a1.id, 'parent_id' => a1.parent_id, "class" => "jstree-checked"}},
      {'data' => a2.title, 'attr' => {'node_id' => a2.id, 'parent_id'=> a2.parent_id}}
    ]
    value['attr'].merge!({'class' => 'jstree-undetermined'})
    value['children'] = children
    value['state'] = 'closed'
    expected_json.push(value)

    value = {'data' => a3.title}
    value['attr'] = { 'node_id' => a3.id, 'parent_id' => a3.parent_id}
    expected_json.push(value)

    assert_hash_equivalent expected_json, json_response
  end

  should 'index action returns an json without children nodes if the parent is not in the parents list' do
    Article.delete_all
    f = fast_create(Folder, :name => 'test folder 1', :profile_id => profile.id)
    a1 = fast_create(TextileArticle, :name => 'test article 1', :profile_id => profile.id, :parent_id => f.id)
    a2 = fast_create(TextileArticle, :name => 'test article 2', :profile_id => profile.id, :parent_id => f.id)
    a3 = fast_create(TextileArticle, :name => 'test article 3', :profile_id => profile.id)

    get :index, :block_id => block.id, :profile => profile.identifier
    json_response = ActiveSupport::JSON.decode(@response.body)
    expected_json = []
    value = {'data' => f.title}
    value['attr'] = { 'node_id' => f.id, 'parent_id' => f.parent_id}
    value['state'] = 'closed'
    expected_json.push(value)

    value = {'data' => a3.title}
    value['attr'] = { 'node_id' => a3.id, 'parent_id' => a3.parent_id}
    expected_json.push(value)

    assert_hash_equivalent expected_json, json_response
  end

end
