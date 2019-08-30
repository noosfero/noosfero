require_relative "../test_helper"

class AbuseComplaintTest < ActiveSupport::TestCase
  should "be related with a reported" do
    reported = fast_create(Profile)
    abuse_complaint = AbuseComplaint.new

    refute abuse_complaint.valid?
    assert abuse_complaint.errors[:reported].any?

    abuse_complaint.reported = reported

    assert abuse_complaint.valid?
  end

  should "become active if number of reports passes environment's lower bound" do
    reported = fast_create(Profile)
    p1 = fast_create(Person)
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    abuse_complaint = AbuseComplaint.create!(reported: reported)

    assert_equal Task::Status::HIDDEN, abuse_complaint.status

    reported.environment.stubs(:reports_lower_bound).returns(2)
    r1 = AbuseReport.new(reason: "some reason").tap do |a|
      a.reporter = p1
      a.abuse_complaint = abuse_complaint
    end.save
    r2 = AbuseReport.new(reason: "some reason").tap do |a|
      a.reporter = p2
      a.abuse_complaint = abuse_complaint
    end.save
    r3 = AbuseReport.new(reason: "some reason").tap do |a|
      a.reporter = p3
      a.abuse_complaint = abuse_complaint
    end.save

    assert_equal Task::Status::ACTIVE, abuse_complaint.status
  end

  should "start with hidden status" do
    t = AbuseComplaint.create
    assert_equal Task::Status::HIDDEN, t.status
  end

  should "be destroyed with reported" do
    reported = fast_create(Profile)
    reported_id = reported.id
    abuse_complaint = AbuseComplaint.create!(reported: reported)

    assert AbuseComplaint.find_by(requestor_id: reported_id), "AbuseComplaint was not created!"

    reported.destroy

    refute AbuseComplaint.find_by(requestor_id: reported_id), "AbuseComplaint still exist!"
  end

  should "api_content return abuse_reports" do
    abuse_complaint = AbuseComplaint.create(reported: fast_create(Community))
    abuse1 = create(AbuseReport, reporter: fast_create(Person), abuse_complaint: abuse_complaint, reason: "some reason")
    abuse2 = create(AbuseReport, reporter: fast_create(Person), abuse_complaint: abuse_complaint, reason: "some reason")
    assert_equivalent abuse_complaint.api_content["abuse_reports"].map { |r| r[:id] }, [abuse1.id, abuse2.id]
  end
end
