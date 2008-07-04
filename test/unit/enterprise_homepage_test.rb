require File.dirname(__FILE__) + '/../test_helper'

class EnterpriseHomepageTest < Test::Unit::TestCase
  
  def setup
    @profile = create_user('testing').person
  end
  attr_reader :profile

  should 'provide a proper short description' do
    assert_kind_of String, EnterpriseHomepage.short_description
  end

  should 'provide a proper description' do
    assert_kind_of String, EnterpriseHomepage.description
  end

  should 'accept empty body' do
    a = EnterpriseHomepage.new
    a.expects(:body).returns(nil)
    assert_nothing_raised do
      assert_equal '', a.to_html
    end
  end

end
