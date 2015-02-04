require_relative "../test_helper"

class PostsLimitTest < ActiveSupport::TestCase

  CLASSES = [Blog, Forum]

  should 'limit posts per_page_page' do
    CLASSES.each do |klass|
      object = klass.new
      object.posts_per_page = klass.posts_per_page_limit + 1
      assert_equal klass.posts_per_page_limit, object.posts_per_page
    end
  end
end
