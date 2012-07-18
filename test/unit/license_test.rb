require File.dirname(__FILE__) + '/../test_helper'

class LicenseTest < ActiveSupport::TestCase
  should 'validate presence of name, slug and enviornment' do
    license = License.new
    license.valid?
    assert license.errors.invalid?(:name)
    assert license.errors.invalid?(:slug)
    assert license.errors.invalid?(:environment)

    license.name = 'GPLv3'
    license.slug = 'gplv3'
    license.environment = Environment.default
    license.valid?
    assert !license.errors.invalid?(:name)
    assert !license.errors.invalid?(:slug)
    assert !license.errors.invalid?(:environment)
  end

  should 'fill in slug before creation' do
    license = License.new(:name => 'GPLv3', :environment => Environment.default)
    assert license.valid?
    assert_equal license.name.to_slug, license.slug
  end

  should 'not overwrite slug if it is already fill' do
    license = License.new(:name => 'GPLv3', :slug => 'some-slug', :environment => Environment.default)
    license.valid?
    assert_equal 'some-slug', license.slug
  end
end

