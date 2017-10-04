require_relative "../test_helper"

class HasUploadQuotaTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Profile)
    @kind1 = fast_create(Kind, name: 'K1', environment_id: Environment.default.id)
    @kind2 = fast_create(Kind, name: 'K2', environment_id: Environment.default.id)
    Kind.any_instance.stubs(:type).returns('Profile')

    @profile.kinds << @kind1
    @profile.kinds << @kind2
  end

  should 'return upload quota of the profile' do
    @profile.update_attributes(upload_quota: 300)
    @kind1.update_attributes(upload_quota: 100)
    assert_equal 300.0, @profile.upload_quota
  end

  should 'return nil if upload quota of the profile is empty' do
    @profile.update_attributes(upload_quota: '')
    @kind1.update_attributes(upload_quota: 100)
    assert @profile.upload_quota.nil?
  end

  should 'return zero if upload quota of the profile is zero' do
    @profile.update_attributes(upload_quota: 0)
    @kind1.update_attributes(upload_quota: 100)
    assert_equal 0, @profile.upload_quota
  end

  should 'return upload quota of the kind if profile does not have it' do
    Profile.stubs(:default_quota).returns(250.0)
    @kind1.update_attributes(upload_quota: 500)
    assert_equal 500, @profile.upload_quota
  end

  should 'return unlimited if one of the kinds has unlimited quota' do
    @kind1.update_attributes(upload_quota: '')
    @kind2.update_attributes(upload_quota: 100)
    assert @profile.upload_quota.nil?
  end

  should 'return the largest quota of all profile kinds' do
    @kind1.update_attributes(upload_quota: 100.50)
    @kind2.update_attributes(upload_quota: 700)
    assert_equal 700.0, @profile.upload_quota
  end

  should 'return the default quota for the class if kind does not have it' do
    Profile.stubs(:default_quota).returns(1000.0)
    assert_equal 1000.0, @kind1.upload_quota
  end

  should 'not accept a quota that is not a number' do
    @profile.upload_quota = 'not a number'
    refute @profile.valid?
  end

  should 'not accept a quota that less than zero' do
    @profile.upload_quota = -33.5
    refute @profile.valid?
  end

end
