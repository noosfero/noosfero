require_relative "../test_helper"

class QualifierCertifierTest < ActiveSupport::TestCase

  should 'connect certifiers and qualifiers' do
    env_one = fast_create(Environment)
    qualifier = env_one.qualifiers.create(:name => 'Qualifier')
    certifier = env_one.certifiers.create(:name => 'Certifier')

    QualifierCertifier.new.tap do |qc|
      qc.qualifier = qualifier
      qc.certifier = certifier
    end.save!

    assert_includes certifier.qualifiers, qualifier
    assert_includes qualifier.certifiers, certifier
  end

end
