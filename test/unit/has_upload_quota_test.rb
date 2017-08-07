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
    @profile.metadata['quota'] = 300.0; @profile.save
    @kind1.metadata['quota'] = 100.0; @kind1.save
    assert_equal 300.0, @profile.upload_quota
  end

  should 'return nil if upload quota of the profile is empty' do
    @profile.metadata['quota'] = ''; @profile.save
    @kind1.metadata['quota'] = 100.0; @kind1.save
    assert @profile.upload_quota.nil?
  end

  should 'return zero if upload quota of the profile is zero' do
    @profile.metadata['quota'] = 0; @profile.save
    @kind1.metadata['quota'] = 100.0; @kind1.save
    assert_equal 0, @profile.upload_quota
  end

  should 'return upload quota of the kind if profile does not have it' do
    Profile.stubs(:default_quota).returns(250.0)
    @kind1.metadata['quota'] = 500; @kind1.save
    assert_equal 500, @profile.upload_quota
  end

  should 'return unlimited if one of the kinds has unlimited quota' do
    @kind1.metadata['quota'] = ''; @kind1.save
    @kind2.metadata['quota'] = 100.0; @kind2.save
    assert @profile.upload_quota.nil?
  end

  should 'return the largest quota of all profile kinds' do
    @kind1.metadata['quota'] = 100.0; @kind1.save
    @kind2.metadata['quota'] = 700.0; @kind2.save
    assert_equal 700.0, @profile.upload_quota
  end

  should 'return the default quota for the class if kind does not have it' do
    Profile.stubs(:default_quota).returns(1000.0)
    assert_equal 1000.0, @kind1.upload_quota
  end

  should 'not save object with invalid upload quota' do
    @profile.metadata['quota'] = 'not a number'
    refute @profile.valid?
  end

end
