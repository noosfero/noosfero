require File.dirname(__FILE__) + '/../test_helper'

class OrganizationInfoTest < Test::Unit::TestCase
  fixtures :organization_infos

  def test_numericality_year
    count = OrganizationInfo.count

    oi = OrganizationInfo.new
    oi.foundation_year = 'xxxx'
    oi.valid?
    assert oi.errors.invalid?(:foundation_year)

    oi.foundation_year = 20.07
    oi.valid?
    assert oi.errors.invalid?(:foundation_year)
    
    oi.foundation_year = 2007
    oi.valid?
    assert ! oi.errors.invalid?(:foundation_year)
  end
end
