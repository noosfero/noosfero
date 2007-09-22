require File.dirname(__FILE__) + '/../test_helper'

class DomainTest < Test::Unit::TestCase
  fixtures :domains, :virtual_communities, :profiles

  # Replace this with your real tests.
  def test_domain_name_format
    c = Domain.new
    assert !c.valid?
    assert c.errors.invalid?(:name)

    c.name = 'bliblibli'
    assert !c.valid?
    assert c.errors.invalid?(:name)

    c.name = 'EXAMPLE.NET'
    assert !c.valid?
    assert c.errors.invalid?(:name)

    c.name = 'test.net'
    c.valid?
    assert !c.errors.invalid?(:name)
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
    Domain.create(:name => 'example.net')
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

end
