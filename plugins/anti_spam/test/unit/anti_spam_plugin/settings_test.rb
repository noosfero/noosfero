require 'test_helper'

class AntiSpamSettingsTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.new
    @settings = AntiSpamPlugin::Settings.new(@environment)
  end

  should 'store setttings in environment' do
    @settings.host = 'foo.com'
    @settings.api_key = '1234567890'
    assert_equal 'foo.com', @environment.settings[:anti_spam_plugin][:host]
    assert_equal '1234567890', @environment.settings[:anti_spam_plugin][:api_key]
    assert_equal 'foo.com', @settings.host
    assert_equal '1234567890', @settings.api_key
  end

  should 'save environment on save' do
    @environment.expects(:save!)
    @settings.save!
  end

  should 'use TypePad AntiSpam by default' do
    assert_equal 'api.antispam.typepad.com', @settings.host
  end


end
