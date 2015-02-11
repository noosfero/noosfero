require 'abstract_unit'

# Don't change '/../temp/' cavalierly or you might hose something you don't want hosed
FILE_STORE_PATH = File.expand_path('../../../temp/test_cache', __FILE__)

class CachingController < ActionController::Base
  abstract!

  self.cache_store = :file_store, FILE_STORE_PATH
end

class FunctionalCachingController < CachingController
  def js_fragment_cached_with_partial
    respond_to do |format|
      format.js
    end
  end

  def formatted_fragment_cached
    respond_to do |format|
      format.js
    end
  end
end

class FunctionalFragmentCachingTest < ActionController::TestCase
  def setup
    super
    @store = ActiveSupport::Cache::MemoryStore.new
    @controller = FunctionalCachingController.new
    @controller.perform_caching = true
    @controller.cache_store = @store
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_fragment_caching_in_rjs_partials
    xhr :get, :js_fragment_cached_with_partial
    assert_response :success
    assert_match(/Old fragment caching in a partial/, @response.body)
    assert_match "Old fragment caching in a partial", @store.instance_variable_get('@data').values.first.value
  end
end
