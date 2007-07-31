require File.dirname(__FILE__) + '/../test_helper'

class EnterpriseTest < Test::Unit::TestCase
  fixtures :profiles, :virtual_communities, :users, :comatose_pages

  def test_identifier_validation
    p = Enterprise.new
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'with space'
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'áéíóú'
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'rightformat2007'
    p.valid?
    assert ! p.errors.invalid?(:identifier)

    p.identifier = 'rightformat'
    p.valid?
    assert ! p.errors.invalid?(:identifier)

    p.identifier = 'right_format'
    p.valid?
    assert ! p.errors.invalid?(:identifier)
  end

  def test_has_domains
    p = Enterprise.new
    assert_kind_of Array, p.domains
  end

  def test_belongs_to_virtual_community_and_has_default
    p = Enterprise.new
    assert_kind_of VirtualCommunity, p.virtual_community
  end

  def test_cannot_rename
    p1 = profiles(:johndoe)
    assert_raise ArgumentError do
      p1.identifier = 'bli'
    end
  end

  def test_numericality_year
    count = Enterprise.count

    e = Enterprise.new(:identifier => 'test_numericality_year', :name => 'numeric_year')
    e.foundation_year = 'xxxx'
    e.valid?
    assert e.errors.invalid?(:foundation_year)

    e.foundation_year = 20.07
    e.valid?
    assert e.errors.invalid?(:foundation_year)
    
    e.foundation_year = 2007
    e.valid?
    assert ! e.errors.invalid?(:foundation_year)

  end

end
