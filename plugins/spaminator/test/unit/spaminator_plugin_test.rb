require 'test_helper'

class SpaminatorPluginTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @settings = Noosfero::Plugin::Settings.new(@environment, SpaminatorPlugin)
  end

  attr_accessor :environment, :settings

  should 'schedule a scan if not already scanning' do
    settings.scanning = true
    settings.save!
    assert_no_difference 'Delayed::Job.count' do
      SpaminatorPlugin.schedule_scan(environment)
    end

    settings.scanning = false
    settings.save!
    assert_difference 'Delayed::Job.count', 1 do
      SpaminatorPlugin.schedule_scan(environment)
    end
  end

end
