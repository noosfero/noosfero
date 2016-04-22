class SpaminatorPlugin::Report < ApplicationRecord

  serialize :failed, Hash

  belongs_to :environment

  validates_presence_of :environment

  attr_accessible :environment

  scope :from_environment, -> environment { where :environment_id => environment }

  after_initialize do |report|
    report.failed = {:people => [], :comments => []} if report.failed.blank?
  end

  def spams
    spams_by_no_network + spams_by_content
  end

  def spammers
    spammers_by_no_network + spammers_by_comments
  end

  def formated_date
    created_at.strftime("%Y-%m-%d")
  end

  def details
    # TODO Implement some decent visualization
    inspect
  end

end
