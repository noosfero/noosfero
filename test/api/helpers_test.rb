require_relative 'test_helper'
require 'noosfero/api/helpers'

class APIHelpersTest < ActiveSupport::TestCase

  include Noosfero::API::APIHelpers

  def setup
    @headers = {}
  end

  attr_accessor :headers

  should 'get the current user with valid token' do
    user = create_user('someuser')
    user.generate_private_token!
    self.params = {:private_token => user.private_token}
    assert_equal user, current_user
  end

  should 'get the current user with valid token in header' do
    user = create_user('someuser')
    user.generate_private_token!
    headers['Private-Token'] = user.private_token
    assert_equal user, current_user
  end

  should 'get the current user even with expired token' do
    user = create_user('someuser')
    user.generate_private_token!
    user.private_token_generated_at = DateTime.now.prev_year
    user.save
    self.params = {:private_token => user.private_token}
    assert_equal user, current_user
  end

  should 'get the person of current user' do
    user = create_user('someuser')
    user.generate_private_token!
    self.params = {:private_token => user.private_token}
    assert_equal user.person, current_person
  end

#  #FIXME see how to make this test. Get the current_user variable
#  should 'set current_user to nil after logout' do
#    user = create_user('someuser')
#    user.stubs(:private_token_expired?).returns(false)
#    User.stubs(:find_by(private_token).returns: user)
#    assert_not_nil current_user
#    assert false
#    logout
#  end

  should 'limit be defined as the params limit value' do
    local_limit = 30
    self.params= {:limit => local_limit}
    assert_equal local_limit, limit
  end

  should 'return default limit if the limit parameter is minor than zero' do
    self.params= {:limit => -1}
    assert_equal 20, limit
  end

  should 'the default limit be 20' do
    assert_equal 20, limit
  end

  should 'the beginning of the period be the first existent date if no from date is passsed as parameter' do
    assert_equal Time.at(0).to_datetime, period(nil, nil).to_a[0]
  end

  should 'the beginning of the period be from date passsed as parameter' do
    from = DateTime.now
    assert_equal from, period(from, nil).min
  end

  should 'the end of the period be now if no until date is passsed as parameter' do
    assert_in_delta DateTime.now, period(nil, nil).max
  end

  should 'the end of the period be until date passsed as parameter' do
    until_date = DateTime.now
    assert_equal until_date, period(nil, until_date).max
  end

  should 'parse_content_type return nil if its blank' do
    assert_nil parse_content_type("")
  end

  should 'parse_content_type be an array' do
    assert_kind_of Array, parse_content_type("text_article")
  end

  should 'parse_content_type return all content types as an array' do
    assert_equivalent ['TextArticle','TinyMceArticle'], parse_content_type("TextArticle,TinyMceArticle")
  end

  should 'find_article return article by id in list passed for user with permission' do
    user = create_user('someuser')
    a = fast_create(Article, :profile_id => user.person.id)
    fast_create(Article, :profile_id => user.person.id)
    fast_create(Article, :profile_id => user.person.id)

    user.generate_private_token!
    self.params = {private_token: user.private_token}
    User.expects(:find_by).with(private_token: user.private_token).returns(user)
    assert_equal a, find_article(user.person.articles, a.id)
  end

  should 'find_article return forbidden when a user try to access an article without permission' do
    user = create_user('someuser')
    p = fast_create(Profile)
    a = fast_create(Article, :published => false, :profile_id => p.id)
    fast_create(Article, :profile_id => p.id)

    user.generate_private_token!
    self.params = {private_token: user.private_token}
    User.expects(:find_by).with(private_token: user.private_token).returns(user)
    assert_equal 403, find_article(p.articles, a.id).last
  end

  should 'make_conditions_with_parameter return no created at parameter if it was not defined from or until parameters' do
    assert_nil make_conditions_with_parameter[:created_at]
  end

  should 'make_conditions_with_parameter return created_at parameter if from period is defined' do
    assert_not_nil make_conditions_with_parameter(:from => '2010-10-10')[:created_at]
  end

  should 'make_conditions_with_parameter return created_at parameter if from period is defined as string' do
    assert_not_nil make_conditions_with_parameter('from' => '2010-10-10')[:created_at]
  end

  should 'make_conditions_with_parameter return created_at parameter if until period is defined' do
    assert_not_nil make_conditions_with_parameter(:until => '2010-10-10')[:created_at]
  end

  should 'make_conditions_with_parameter return created_at parameter if until period is defined as string' do
    assert_not_nil make_conditions_with_parameter('until' => '2010-10-10')[:created_at]
  end

  should 'make_conditions_with_parameter return created_at as the first existent date as parameter if only until is defined' do
    assert_equal Time.at(0).to_datetime, make_conditions_with_parameter(:until => '2010-10-10')[:created_at].min
  end

  should 'make_conditions_with_parameter: the minimal created_at date be the from date passed as parameter' do
    date = '2010-10-10'
    assert_equal DateTime.parse(date), make_conditions_with_parameter(:from => date)[:created_at].min
  end

  should 'make_conditions_with_parameter: the maximum created_at date be the until date passed as parameter' do
    date = '2010-10-10'
    assert_equal DateTime.parse(date), make_conditions_with_parameter(:until => date)[:created_at].max
  end

  should 'make_conditions_with_parameter return the until date passed as parameter' do
    date = '2010-10-10'
    assert_equal DateTime.parse(date), make_conditions_with_parameter(:from => '2010-10-10')[:created_at].min
  end

  should 'make_conditions_with_parameter return no type parameter if it was not defined any content type' do
    assert_nil make_conditions_with_parameter[:type]
  end

  #test_should_make_order_with_parameters_return_order_if attribute_is_found_at_object_association
  should 'make_order_with_parameters return order if attribute is found at object association' do
    environment = Environment.new
    params = {:order => "name ASC"}
    assert_equal "name ASC", make_order_with_parameters(environment, "articles", params)
  end

  # test added to check for eventual sql injection vunerabillity
  #test_should_make_order_with_parameters_return_default_order_if_attributes_not_exists
  should 'make_order_with_parameters return default order if attributes not exists' do
    environment = Environment.new
    params = {:order => "CRAZY_FIELD ASC"} # quote used to check sql injection vunerabillity
    assert_equal "created_at DESC", make_order_with_parameters(environment, "articles", params)
  end

  should 'make_order_with_parameters return default order if sql injection detected' do
    environment = Environment.new
    params = {:order => "name' ASC"} # quote used to check sql injection vunerabillity
    assert_equal "created_at DESC", make_order_with_parameters(environment, "articles", params)
  end

  should 'make_order_with_parameters return RANDOM() if random is passed' do
    environment = Environment.new
    params = {:order => "random"} # quote used to check sql injection vunerabillity
    assert_equal "RANDOM()", make_order_with_parameters(environment, "articles", params)
  end

  should 'make_order_with_parameters return RANDOM() if random function is passed' do
    environment = Environment.new
    params = {:order => "random()"} # quote used to check sql injection vunerabillity
    assert_equal "RANDOM()", make_order_with_parameters(environment, "articles", params)
  end

  should 'render not_found if endpoint is unavailable' do
    Noosfero::API::API.stubs(:endpoint_unavailable?).returns(true)
    self.expects(:not_found!)

    filter_disabled_plugins_endpoints
  end

  should 'not touch in options when no fields parameter is passed' do
    model = mock
    expects(:present).with(model, {})
    present_partial(model, {})
  end

  should 'fallback to array when fields parameter is not a json when calling present partial' do
    model = mock
    params[:fields] = ['name']
    expects(:present).with(model, {:only => ['name']})
    present_partial(model, {})
  end

  should 'fallback to comma separated string when fields parameter is not an array when calling present partial' do
    model = mock
    params[:fields] = 'name,description'
    expects(:present).with(model, {:only => ['name', 'description']})
    present_partial(model, {})
  end

  should 'accept json as fields parameter when calling present partial' do
    model = mock
    params[:fields] = {only: [:name, {user: [:login]}]}.to_json
    expects(:present).with(model, {:only => ['name', {'user' => ['login']}]})
    present_partial(model, {})
  end

  protected

  def error!(info, status)
    [info, status]
  end

  def params
    @params ||= {}
  end

  def params= value
    @params = value
  end

end
