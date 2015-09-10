class OrganizationRatingsConfig < ActiveRecord::Base

  belongs_to :environment

  attr_accessible :cooldown, :default_rating, :order, :per_page
  attr_accessible :vote_once, :are_moderated, :environment_id

  ORDER_OPTIONS = {recent: _('More Recent'), best: _('Best Ratings')}

  MINIMUM_RATING = 1
  MAX_COOLDOWN = 1000

  validates :default_rating,
            :presence => true, :numericality => {
              greater_than_or_equal_to: MINIMUM_RATING,
              less_than_or_equal_to: 5
            }

  validates :cooldown,
            :presence => true, :numericality => {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: MAX_COOLDOWN
            }

  validates :per_page,
            :presence => true, :numericality => {
              :greater_than_or_equal_to => 5,
              :less_than_or_equal_to  => 20
            }


  def order_options
    ORDER_OPTIONS
  end

  def minimum_ratings
    MINIMUM_RATING
  end

  def max_cooldown
    MAX_COOLDOWN
  end

  class << self
    def instance
      environment = Environment.default
      environment.organization_ratings_config || create(environment_id: environment.id)
    end

    private :new
  end

end
