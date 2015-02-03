require_relative "../test_helper"

class LicenseTest < ActiveSupport::TestCase
  should 'validate presence of name and environment' do
    license = License.new
    license.valid?
    assert license.errors[:name].any?
    assert license.errors[:environment].any?

    license.name = 'GPLv3'
    license.environment = Environment.default
    license.valid?
    assert !license.errors[:name].any?
    assert !license.errors[:environment].any?
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

  should 'allow equal slugs in different environments' do
    e1 = fast_create(Environment)
    e2 = fast_create(Environment)
    License.create!(:name => 'License', :environment => e1)
    license = License.new(:name => 'License', :environment => e2)

    assert license.valid?
  end
end

