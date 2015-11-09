require 'test_helper'

class SpaminatorPlugin::ReportTest < ActiveSupport::TestCase

  should 'must belong to an environment' do
    report = SpaminatorPlugin::Report.new
    report.valid?
    assert report.errors.include?(:environment)

    report.environment = Environment.default
    report.valid?
    refute report.errors.include?(:environment)
  end

  should 'have scope of all reports from an environment' do
    environment = Environment.default
    r1 = SpaminatorPlugin::Report.create(:environment => environment)
    r2 = SpaminatorPlugin::Report.create(:environment => environment)
    r3 = SpaminatorPlugin::Report.create(:environment => environment)
    r4 = SpaminatorPlugin::Report.create(:environment => fast_create(Environment))

    reports = SpaminatorPlugin::Report.from_environment(environment)

    assert_equal ActiveRecord::Relation, reports.class
    assert_includes reports, r1
    assert_includes reports, r2
    assert_includes reports, r3
    assert_not_includes reports, r4
  end

  should 'initialize failed hash' do
    report = SpaminatorPlugin::Report.new

    assert report.failed.kind_of?(Hash)
    assert report.failed.has_key?(:people)
    assert report.failed.has_key?(:comments)
    assert_equal [], report.failed[:people]
    assert_equal [], report.failed[:comments]
  end

end
