require File.dirname(__FILE__) + '/../test_helper'

class DomainTest < ActiveSupport::TestCase
  fixtures :domains, :environments, :profiles, :users

  def setup
    Domain.clear_cache
  end

  should 'not allow domains without name' do
    domain = Domain.new
    domain.valid?
    assert domain.errors.invalid?(:name)
  end

  should 'not allow domain without dot' do
    domain = Domain.new(:name => 'test')
    domain.valid?
    assert domain.errors.invalid?(:name)
  end

  should 'allow domains with dot' do
    domain = Domain.new(:name => 'test.org')
    domain.valid?
    assert !domain.errors.invalid?(:name)
  end

  should 'not allow domains with upper cased letters' do
    domain = Domain.new(:name => 'tEst.org')
    domain.valid?
    assert domain.errors.invalid?(:name)
  end

  should 'allow domains with hyphen' do
    domain = Domain.new(:name => 'test-domain.org')
    domain.valid?
    assert !domain.errors.invalid?(:name)
  end

  should 'allow domains with underscore' do
    domain = Domain.new(:name => 'test_domain.org')
    domain.valid?
    assert !domain.errors.invalid?(:name)
  end

  def test_owner
    d = Domain.new(:name => 'example.com')
    d.owner = Environment.new(:name => 'Example')
    assert d.save
    assert_kind_of Environment, d.owner
  end

  def test_get_domain_name
    assert_equal 'example.net', Domain.extract_domain_name('www.example.net')
    assert_equal 'example.net', Domain.extract_domain_name('WWW.EXAMPLE.NET')
  end

  def test_name_cannot_have_www
    d = Domain.new
    d.name = 'www.example.net'
    d.valid?
    assert d.errors.invalid?(:name)

    d.name = 'example.net'
    d.valid?
    assert !d.errors.invalid?(:name)
  end

  def test_find_by_name
    Domain.delete_all
    fast_create(Domain, :name => 'example.net')
    d1 = Domain.find_by_name('example.net')
    d2 =  Domain.find_by_name('www.example.net')
    assert !d1.nil?
    assert !d2.nil?
    assert d1 == d2
  end

  def test_unique_name
    Domain.delete_all
    assert Domain.create(:name => 'example.net')

    d = Domain.new(:name => 'example.net')
    assert !d.valid?
    assert d.errors.invalid?(:name)
  end

  def test_environment
    # domain directly linked to Environment
    domain = Domain.find_by_name('colivre.net')
    assert_kind_of Environment, domain.owner
    assert_kind_of Environment, domain.environment

    # domain linked to Profile
    domain = Domain.find_by_name('johndoe.net')
    assert_kind_of Profile, domain.owner
    assert_kind_of Environment, domain.environment
  end

  def test_profile
    # domain linked to profile
    assert_not_nil Domain.find_by_name('johndoe.net').profile
    # domain linked to Environment
    assert_nil Domain.find_by_name('colivre.net').profile
  end

  def test_hosted_domain
    assert_equal false, Domain.hosting_profile_at('example.com')

    profile = create_user('hosted_user').person
    Domain.create!(:name => 'example.com', :owner => profile)
    assert_equal true, Domain.hosting_profile_at('example.com')
  end

  def test_not_report_profile_hosted_for_environment_domains
    Domain.create!(:name => 'example.com', :owner => Environment.default)
    assert_equal false, Domain.hosting_profile_at('example.com')
  end

  should 'not crash if key is not defined' do
    domain = fast_create(Domain, :name => 'domain-without-key')
    assert_nil domain.google_maps_key
  end

  should 'return key if defined' do
    domain = fast_create(Domain, :name => 'domain-with-key', :google_maps_key => 'DOMAIN_KEY')
    assert_equal 'DOMAIN_KEY', domain.google_maps_key
  end

end
