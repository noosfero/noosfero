class ProfileSuggestion < ActiveRecord::Base
  belongs_to :person
  belongs_to :suggestion, :class_name => 'Profile', :foreign_key => :suggestion_id

  attr_accessible :person, :suggestion, :suggestion_type, :categories, :similarity, :enabled

  before_create do |profile_suggestion|
    profile_suggestion.suggestion_type = self.suggestion.class.to_s
  end

  acts_as_having_settings :field => :categories

  validate :must_be_a_valid_category, :on => :create
  def must_be_a_valid_category
    if categories.keys.map { |cat| self.respond_to?(cat)}.include?(false)
      errors.add(:categories, 'Category must be valid')
    end
  end

  validates_uniqueness_of :suggestion_id, :scope => [ :person_id ]

  CATEGORIES = {
    :common_friends => _('Friends in common'),
    :common_communities => _('Communities in common'),
    :common_tags => _('Tags in common')
  }

  CATEGORIES.keys.each do |category|
    settings_items category.to_sym
    attr_accessible category.to_sym
  end
  def disable
    self.enabled = false
    self.save
  end

end
