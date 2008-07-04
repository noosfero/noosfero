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

  should 'display profile info' do
    e = Enterprise.create!(:name => 'my test enterprise', :identifier => 'mytestenterprise', :contact_email => 'ent@noosfero.foo.bar', :contact_phone => '5555 5555')
    a = EnterpriseHomepage.new(:name => 'article homepage')
    e.articles << a
    result = a.to_html
    assert_match /ent@noosfero.foo.bar/, result
    assert_match /5555 5555/, result
  end

end
