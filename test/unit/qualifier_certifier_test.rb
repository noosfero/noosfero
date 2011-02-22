require File.dirname(__FILE__) + '/../test_helper'

class QualifierCertifierTest < ActiveSupport::TestCase

  should 'qualifier has many certifiers' do
    env_one = fast_create(Environment)
    qualifier = Qualifier.create(:name => 'Qualifier', :environment => env_one)
    certifier = Certifier.create(:name => 'Certifier', :environment => env_one)

    QualifierCertifier.create(:qualifier => qualifier, :certifier => certifier)

    assert_includes qualifier.certifiers, certifier
  end

  should 'certifier has many qualifiers' do
    env_one = fast_create(Environment)
    qualifier = Qualifier.create(:name => 'Qualifier', :environment => env_one)
    certifier = Certifier.create(:name => 'Certifier', :environment => env_one)

    QualifierCertifier.create(:qualifier => qualifier, :certifier => certifier)

    assert_includes certifier.qualifiers, qualifier
  end

end
