require_relative "../test_helper"

class HttpCachingTest < ActionController::IntegrationTest

  def setup
    create_user('joao', password: 'test', password_confirmation: 'test').activate
  end

  test 'home page, default configuration' do
    get '/'
    assert_cache(5.minutes)
    assert_no_cookies
  end

  test 'home page, custom config' do
    set_env_config(home_cache_in_minutes: 10)
    get '/'
    assert_cache(10.minutes)
  end

  test 'search results, default config' do
    get '/search', query: 'anything'
    assert_cache(15.minutes)
  end

  test 'search results, custom config' do
    set_env_config(general_cache_in_minutes: 30)
    get '/search', query: 'anything'
    assert_cache(30.minutes)
  end

  test 'profile page, default config' do
    get "/profile/joao"
    assert_cache(15.minutes)
  end

  test 'profile page, custom config' do
    set_env_config(profile_cache_in_minutes: 60)
    get "/profile/joao"
    assert_cache(60.minutes)
  end

  test 'account controller' do
    get '/account/login'
    assert_no_cache
  end

  test 'profile admin' do
    login 'joao', 'test'
    get "/myprofile/joao"
    assert_no_cache
  end

  test 'environment admin' do
    Environment.default.add_admin(Profile['joao'])
    get '/admin'
    assert_no_cache
  end

  test 'logged in, home page' do
    login 'joao', 'test'
    get '/'
    assert_no_cache
  end

  test 'logged in, profile home' do
    login 'joao', 'test'
    get '/joao'
    assert_no_cache
  end

  test 'logged in, profile page' do
    login 'joao', 'test'
    get '/profile/joao'
    assert_no_cache
  end

  test 'private community profile should not return cache headers' do
    create_private_community('the-community')

    get "/profile/the-community"
    assert_response 403
    assert_no_cache
  end

  test 'private community content should not return cache headers' do
    community = create_private_community('the-community')
    create(Article, profile_id: community.id, name: 'Test page')

    get "/the-community/test-page"
    assert_response 403
    assert_no_cache
  end

  test 'user data, not logged in' do
    get '/account/user_data', {}, { 'X-Requested-With' => 'XMLHttpRequest'}
    assert_no_cookies
  end

  protected

  def set_env_config(data)
    env = Environment.default
    data.each do |key, value|
      env.send("#{key}=", value)
    end
    env.save!
  end

  def create_private_community(identifier)
    community = fast_create(Community, identifier: identifier)
    community.public_profile = false
    community.save!
    community
  end

  def assert_no_cache
    assert(cache_parts == ['max-age=0', 'must-revalidate', 'private'] || cache_parts == ['no-cache'], "should not set cache headers (found #{cache_parts.inspect})")
  end

  def assert_public_cache
    assert_includes cache_parts, 'public'
  end

  def cache_parts
    @cache_parts ||= response.headers['Cache-Control'].split(/\s*,\s*/).sort
  end

  def assert_cache(valid_for)
    assert_includes cache_parts, "max-age=#{valid_for}"
  end

  def assert_no_cookies
    assert_equal({}, response.cookies.to_hash)
  end

  def assert_cookie(cookie_name)
    assert_includes response.cookies.keys, cookie_name
  end

end

