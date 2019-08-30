class AbuseReport < ApplicationRecord
  attr_accessible :content, :reason

  belongs_to :reporter, class_name: "Person", optional: true
  belongs_to :abuse_complaint, optional: true
  has_many :reported_images, dependent: :destroy

  validates_presence_of :reporter, :abuse_complaint, :reason
  validates_uniqueness_of :reporter_id, scope: :abuse_complaint_id

  xss_terminate sanitize: [:reason]

  after_create do |abuse_report|
    abuse_report.abuse_complaint.save!
  end
end
