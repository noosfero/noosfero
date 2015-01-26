require_relative "../test_helper"

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
    assert abuse_report.invalid?(:reporter)
    assert abuse_report.invalid?(:abuse_complaint)

    abuse_report.reporter = reporter
    abuse_report.abuse_complaint = abuse_complaint

    assert abuse_report.valid?
  end

  should 'not allow more than one report by a user to the same complaint' do
    abuse_report = AbuseReport.new(:reason => 'some reason')
    abuse_report.reporter = reporter
    abuse_report.abuse_complaint = abuse_complaint
    abuse_report.save!
    assert_raise ActiveRecord::RecordInvalid do
      another_abuse = AbuseReport.new(:reason => 'some reason')
      another_abuse.reporter = reporter
      another_abuse.abuse_complaint = abuse_complaint
      another_abuse.save!
    end
  end
end

