require 'test_helper'

class ProfileTest < ActiveSupport::TestCase

  def setup
    @macro = VariablesPlugin::Profile.new
    @macro.context = mock()
    @profile = fast_create(Community)
    @macro.context.stubs(:profile).returns(@profile)
  end

  attr_reader :macro, :profile

  should 'have a configuration' do
    assert VariablesPlugin::Profile.configuration
  end

  should 'substitute the {profile} variable by the profile idenfifier' do
    html = 'the profile identifier is {profile}'
    content = macro.parse({}, html, profile)
    assert_equal "the profile identifier is #{profile.identifier}", content
  end

  should 'substitute the {name} variable by the profile name' do
    html = 'the profile name is {name}'
    content = macro.parse({}, html, profile)
    assert_equal "the profile name is #{profile.name}", content
  end

  should 'do not change the content if the variable is not supported' do
    html = 'the variable {unsupported} is not supported'
    content = macro.parse({}, html, profile)
    assert_equal html, content
  end

  should 'do nothing out of profile context' do
    macro.context.stubs(:profile).returns(nil)
    html = 'there is no {support} out of profile context'
    content = macro.parse({}, html, profile)
    assert_equal html, content
  end

end
