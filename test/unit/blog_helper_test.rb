require File.dirname(__FILE__) + '/../test_helper'

class BlogHelperTest < Test::Unit::TestCase

  include BlogHelper

  def setup
    stubs(:show_date).returns('')
    @profile = create_user('blog_helper_test').person
  end
  attr :profile

  should 'add real tests' do
    assert true
  end

end
