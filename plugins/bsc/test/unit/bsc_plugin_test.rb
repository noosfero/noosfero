require 'test_helper'

class BscPluginTest < ActiveSupport::TestCase

  VALID_CNPJ = '94.132.024/0001-48'

  should 'add profile controller filter correctly' do
    bsc_plugin = BscPlugin.new
    person = fast_create(Person)
    context = mock()
    context.stubs(:profile).returns(person)
    context.stubs(:params).returns({:profile => person.identifier})
    context.stubs(:user).returns(person)
    context.stubs(:environment).returns(person.environment)
    bsc_plugin.stubs(:context).returns(context)

    assert_nil bsc_plugin.profile_controller_filters.first[:block].call
    assert_nil bsc_plugin.content_viewer_controller_filters.first[:block].call

    enterprise = fast_create(Enterprise, :validated => false)
    enterprise.bsc = BscPlugin::Bsc.create!({:business_name => 'Sample Bsc', :identifier => 'sample-bsc', :company_name => 'Sample Bsc Ltda.', :cnpj => VALID_CNPJ})
    enterprise.save!
    context.stubs(:profile).returns(enterprise)
    context.stubs(:params).returns({:profile => enterprise.identifier})
    context.stubs(:environment).returns(enterprise.environment)

    assert_raise NameError do
      bsc_plugin.profile_controller_filters.first[:block].call
    end
    assert_raise NameError do
      bsc_plugin.content_viewer_controller_filters.first[:block].call
    end
  end
end
