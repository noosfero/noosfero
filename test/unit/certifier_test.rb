require File.dirname(__FILE__) + '/../test_helper'

class CertifierTest < Test::Unit::TestCase

  should 'have link' do
    certifier = Certifier.new

    assert_equal '', certifier.link

    certifier.link = 'http://noosfero.org'
    assert_equal 'http://noosfero.org', certifier.link
  end

  should 'environment is mandatory' do
    certifier = Certifier.new(:name => 'Certifier without environment')
    assert !certifier.valid?

    certifier.environment = fast_create(Environment)
    assert certifier.valid?
  end

  should 'belongs to environment' do
    env_one = fast_create(Environment)
    certifier_from_env_one = Certifier.create(:name => 'Certifier from environment one', :environment => env_one)

    env_two = fast_create(Environment)
    certifier_from_env_two = Certifier.create(:name => 'Certifier from environment two', :environment => env_two)

    assert_includes env_one.certifiers, certifier_from_env_one
    assert_not_includes env_one.certifiers, certifier_from_env_two
  end

  should 'name is mandatory' do
    env_one = fast_create(Environment)
    certifier = Certifier.new(:environment => env_one)
    assert !certifier.valid?

    certifier.name = 'Certifier name'
    assert certifier.valid?
  end

end
