class AverageRatingBlock < Block
  include RatingsHelper

  def self.description
    _('Organization Average Rating')
  end

  def help
    _('This block displays the organization average rating.')
  end

  def cacheable?
    false
  end
end
