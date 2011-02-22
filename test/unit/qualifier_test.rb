require File.dirname(__FILE__) + '/../test_helper'

class QualifierTest < ActiveSupport::TestCase

  should 'environment is mandatory' do
    qualifier = Qualifier.new(:name => 'Qualifier without environment')
    assert !qualifier.valid?

    qualifier.environment = fast_create(Environment)
    assert qualifier.valid?
  end

  should 'belongs to environment' do
    env_one = fast_create(Environment)
    qualifier_from_env_one = Qualifier.create(:name => 'Qualifier from environment one', :environment => env_one)

    env_two = fast_create(Environment)
    qualifier_from_env_two = Qualifier.create(:name => 'Qualifier from environment two', :environment => env_two)

    assert_includes env_one.qualifiers, qualifier_from_env_one
    assert_not_includes env_one.qualifiers, qualifier_from_env_two
  end

  should 'name is mandatory' do
    env_one = fast_create(Environment)
    qualifier = Qualifier.new(:environment => env_one)
    assert !qualifier.valid?

    qualifier.name = 'Qualifier name'
    assert qualifier.valid?
  end

end
