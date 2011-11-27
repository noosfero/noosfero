require File.dirname(__FILE__) + '/../test_helper'

class AbuseReportTest < ActiveSupport::TestCase

  def setup
    @reported = fast_create(Profile)
    @reporter = fast_create(Person)
    @abuse_complaint = AbuseComplaint.create!(:reported => @reported)
  end

  attr_accessor :reporter, :abuse_complaint

  should 'ensure presence of complaint, reporter and reported' do
    abuse_report = AbuseReport.new(:reason => 'some reason')

    assert !abuse_report.valid?
    assert abuse_report.errors.invalid?(:reporter)
    assert abuse_report.errors.invalid?(:abuse_complaint)

    abuse_report.reporter = reporter
    abuse_report.abuse_complaint = abuse_complaint

    assert abuse_report.valid?
  end

  should 'not allow more than one report by a user to the same complaint' do
    abuse_report = AbuseReport.create!(:reporter => reporter, :abuse_complaint => abuse_complaint, :reason => 'some reason')
    assert_raise ActiveRecord::RecordInvalid do
      another_abuse = AbuseReport.create!(:reporter => reporter, :abuse_complaint => abuse_complaint, :reason => 'some reason')
    end
  end
end

