require 'test_helper'

class BscPlugin::AssociateEnterpriseTest < ActiveSupport::TestCase
  VALID_CNPJ = '94.132.024/0001-48'

  def setup
    @enterprise = fast_create(Enterprise)
    @person = create_user('user').person
    @bsc = BscPlugin::Bsc.create!(:business_name => 'Sample Bsc', :company_name => 'Sample Bsc Ltda.', :identifier => 'sample-bsc', :cnpj => VALID_CNPJ)
  end

  attr_accessor :enterprise, :person, :bsc

  should 'associate enteprise with bsc after perform' do
    task = BscPlugin::AssociateEnterprise.create!(:requestor => person, :target => enterprise, :bsc => bsc)
    task.perform
    bsc.reload

    assert_includes bsc.enterprises, enterprise
  end

  should 'notify enterprise when some bsc create the request' do
    enterprise.contact_email = 'enterprise@bsc.org'
    enterprise.save!
    assert_difference ActionMailer::Base.deliveries, :count, 1 do
      BscPlugin::AssociateEnterprise.create!(:requestor => person, :target => enterprise, :bsc => bsc)
    end
    assert_includes ActionMailer::Base.deliveries.last.to, enterprise.contact_email
  end

  should 'notify requestor when some enterprise reject the request' do
    person.email = 'person@bsc.org'
    person.save!
    task = BscPlugin::AssociateEnterprise.create!(:requestor => person, :target => enterprise, :bsc => bsc)
    assert_difference ActionMailer::Base.deliveries, :count, 1 do
      task.cancel
    end
    assert_includes ActionMailer::Base.deliveries.last.to, person.contact_email
  end

  should 'notify requestor when some enterprise accept the request' do
    person.email = 'person@bsc.org'
    person.save!
    task = BscPlugin::AssociateEnterprise.create!(:requestor => person, :target => enterprise, :bsc => bsc)
    assert_difference ActionMailer::Base.deliveries, :count, 1 do
      task.finish
    end
    assert_includes ActionMailer::Base.deliveries.last.to, person.contact_email
  end

end

