class OrganizationRating < ApplicationRecord
  belongs_to :person
  belongs_to :organization
  belongs_to :comment

  attr_accessible :value, :person, :organization, :comment

  validates :value,
            :presence => true, :inclusion => {
              in: 1..5, message: _("must be between 1 and 5")
            }

  validates :organization_id, :person_id,
            :presence => true

  def display_full_info_to? person
      (person.is_admin? || person == self.person ||
      self.organization.is_admin?(person))
  end

  def task_status
    tasks = CreateOrganizationRatingComment.where(:target_id => self.organization.id, :requestor_id => self.person.id)
    task = tasks.detect{ |t| t.organization_rating_id == self.id }
    task.status if task.present?
  end

  def self.statistics_for_profile organization
    ratings = OrganizationRating.where(organization_id: organization)
    average = ratings.average(:value)
    total = ratings.size

    if average
      average = (average - average.truncate) >= 0.5 ? average.ceil : average.floor
    end
    { average: average, total: total }
  end

end
