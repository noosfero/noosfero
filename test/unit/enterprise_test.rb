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

  def test_belongs_to_environment_and_has_default
    p = Enterprise.new
    assert_kind_of Environment, p.environment
  end

  def test_cannot_rename
    p1 = profiles(:johndoe)
    assert_raise ArgumentError do
      p1.identifier = 'bli'
    end
  end

  def test_approve
    e = Enterprise.create(:identifier => 'bli', :name => 'Bli')
    assert !e.approved?
    e.approve
    assert e.approved?
  end

  def test_reject
    e = Enterprise.create(:identifier => 'bli', :name => 'Bli')
    assert !e.rejected?
    e.reject
    assert e.rejected?
  end

  def test_cannot_be_activated_without_approval
    e = Enterprise.create(:identifier => 'bli', :name => 'Bli')
    assert !e.approved
    e.activate
    assert !e.valid?
    e.approve
    e.activate
    assert e.valid?
  end
end
