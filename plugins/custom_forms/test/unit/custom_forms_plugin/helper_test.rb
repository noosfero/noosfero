require 'test_helper'
require_relative '../../../lib/custom_forms_plugin/helper'

class CustomFormsPlugin::HelperTest < ActiveSupport::TestCase
  include CustomFormsPlugin::Helper

  should 'get proper time status' do
    profile = fast_create(Profile)
    s1 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Survey 1', :identifier => 'survey-1', :begining => Time.now + 1.day, :ending => Time.now + 2.days)
    s2 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Survey 2', :identifier => 'survey-2', :begining => Time.now - 1.day, :ending => Time.now + 1.day)
    s3 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Survey 3', :identifier => 'survey-3', :begining => Time.now - 2.days, :ending => Time.now - 1.day)
    s4 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Survey 4', :identifier => 'survey-4', :begining => Time.now + 1.day)
    s5 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Survey 5', :identifier => 'survey-5', :begining => Time.now - 1.day)
    s6 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Survey 6', :identifier => 'survey-6', :ending => Time.now + 1.day)
    s7 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Survey 7', :identifier => 'survey-7', :ending => Time.now - 1.day)
    s8 = CustomFormsPlugin::Form.create!(:profile => profile, :name => 'Survey 8', :identifier => 'survey-8')

    assert time_status(s1) =~ /left to open$/
    assert time_status(s2) =~ /left to close$/
    assert time_status(s3) =~ /^Closed$/
    assert time_status(s4) =~ /left to open$/
    assert time_status(s5) =~ /^Always open$/
    assert time_status(s6) =~ /left to close$/
    assert time_status(s7) =~ /^Closed$/
    assert time_status(s8) =~ /^Always open$/
  end
end

