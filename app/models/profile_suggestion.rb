class ProfileSuggestion < ActiveRecord::Base
  belongs_to :person
  belongs_to :suggestion, :class_name => 'Profile', :foreign_key => :suggestion_id

  attr_accessible :person, :suggestion, :suggestion_type, :categories, :enabled

  before_create do |profile_suggestion|
    profile_suggestion.suggestion_type = self.suggestion.class.to_s
  end

  after_destroy do |profile_suggestion|
    self.class.generate_profile_suggestions(profile_suggestion.person)
  end

  acts_as_having_settings :field => :categories

  validate :must_be_a_valid_category, :on => :create
  def must_be_a_valid_category
    if categories.keys.map { |cat| self.respond_to?(cat)}.include?(false)
      errors.add(:categories, 'Category must be valid')
    end
  end

  validates_uniqueness_of :suggestion_id, :scope => [ :person_id ]
  scope :of_person, :conditions => { :suggestion_type => 'Person' }
  scope :of_community, :conditions => { :suggestion_type => 'Community' }
  scope :enabled, :conditions => { :enabled => true }

  # {:category_type => ['category-icon', 'category-label']}
  CATEGORIES = {
    :common_friends => ['menu-people', _('Friends in common')],
    :common_communities => ['menu-community',_('Communities in common')],
    :common_tags => ['edit', _('Tags in common')]
  }

  CATEGORIES.keys.each do |category|
    settings_items category.to_sym
    attr_accessible category.to_sym
  end

  def category_icon(category)
    'icon-' + ProfileSuggestion::CATEGORIES[category][0]
  end

  def category_label(category)
    ProfileSuggestion::CATEGORIES[category][1]
  end

  RULES = %w[
    people_with_common_friends
    people_with_common_communities
    people_with_common_tags
    communities_with_common_friends
    communities_with_common_tags
  ]

  # Number of suggestions by rule
  SUGGESTIONS_BY_RULE = 10

  # Minimum number of suggestions
  MIN_LIMIT = 15

  # Number of friends in common
  COMMON_FRIENDS = 2

  # Number of communities in common
  COMMON_COMMUNITIES = 2

  # Number of friends in common
  COMMON_TAGS = 2

  def self.register_suggestions(person, suggested_profiles, rule)
    already_suggested_profiles = person.profile_suggestions.map(&:suggestion_id).join(',')
    suggested_profiles = suggested_profiles.where("profiles.id NOT IN (#{already_suggested_profiles})") if already_suggested_profiles.present?
    suggested_profiles = suggested_profiles.limit(SUGGESTIONS_BY_RULE)
    return if suggested_profiles.blank?
    counter = rule.split(/.*_with_/).last
    suggested_profiles.each do |suggested_profile|
      suggestion = person.profile_suggestions.find_or_initialize_by_suggestion_id(suggested_profile.id)
      suggestion.send(counter+'=', suggested_profile.common_count.to_i)
      suggestion.save!
    end
  end

  def self.calculate_suggestions(person)
    ProfileSuggestion::RULES.each do |rule|
      register_suggestions(person, ProfileSuggestion.send(rule, person), rule)
    end
  end

  # If you are about to rewrite the following sql queries, think twice. After
  # that make sure that whatever you are writing to replace it should be faster
  # than how it is now. Yes, sqls are ugly but are fast! And fast is what we
  # need here.

  def self.people_with_common_friends(person)
    person_friends = person.friends.map(&:id)
    return [] if person_friends.blank?
    person.environment.people.
      select("profiles.*, suggestions.count AS common_count").
      joins("
        INNER JOIN (SELECT person_id, count(person_id) FROM
          friendships WHERE friend_id IN (#{person_friends.join(',')}) AND
          person_id NOT IN (#{(person_friends << person.id).join(',')})
          GROUP BY person_id
          HAVING count(person_id) >= #{COMMON_FRIENDS}) AS suggestions
        ON profiles.id = suggestions.person_id")
  end

  def self.people_with_common_communities(person)
    person_communities = person.communities.map(&:id)
    return [] if person_communities.blank?
    person.environment.people.
      select("profiles.*, suggestions.count AS common_count").
      joins("
        INNER JOIN (SELECT common_members.accessor_id, count(common_members.accessor_id) FROM
          (SELECT DISTINCT accessor_id, resource_id FROM
          role_assignments WHERE role_assignments.resource_id IN (#{person_communities.join(',')}) AND
          role_assignments.accessor_id != #{person.id} AND role_assignments.resource_type = 'Profile' AND
          role_assignments.accessor_type = 'Profile') AS common_members
          GROUP BY common_members.accessor_id
          HAVING count(common_members.accessor_id) >= #{COMMON_COMMUNITIES})
        AS suggestions ON profiles.id = suggestions.accessor_id")
  end

  def self.people_with_common_tags(person)
    profile_tags = person.articles.select('tags.id').joins(:tags).map(&:id)
    return [] if profile_tags.blank?
    person.environment.people.
    select("profiles.*, suggestions.count as common_count").
    joins("
      INNER JOIN (
        SELECT results.profiles_id as profiles_id, count(results.profiles_id) FROM (
          SELECT DISTINCT tags.id, profiles.id as profiles_id FROM profiles
          INNER JOIN articles ON articles.profile_id = profiles.id
          INNER JOIN taggings ON taggings.taggable_id = articles.id AND taggings.context = ('tags') AND taggings.taggable_type = 'Article'
          INNER JOIN tags ON tags.id = taggings.tag_id
          WHERE (tags.id in (#{profile_tags.join(',')}) AND profiles.id != #{person.id})) AS results
        GROUP BY results.profiles_id
        HAVING count(results.profiles_id) >= #{COMMON_TAGS})
      as suggestions on profiles.id = suggestions.profiles_id")
  end

  def self.communities_with_common_friends(person)
    person_friends = person.friends.map(&:id)
    return [] if person_friends.blank?
    person.environment.communities.
      select("profiles.*, suggestions.count AS common_count").
      joins("
        INNER JOIN (SELECT common_communities.resource_id, count(common_communities.resource_id) FROM
          (SELECT DISTINCT accessor_id, resource_id FROM
          role_assignments WHERE role_assignments.accessor_id IN (#{person_friends.join(',')}) AND
          role_assignments.accessor_id != #{person.id} AND role_assignments.resource_type = 'Profile' AND
          role_assignments.accessor_type = 'Profile') AS common_communities
          GROUP BY common_communities.resource_id
          HAVING count(common_communities.resource_id) >= #{COMMON_FRIENDS})
        AS suggestions ON profiles.id = suggestions.resource_id")
  end

  def self.communities_with_common_tags(person)
    profile_tags = person.articles.select('tags.id').joins(:tags).map(&:id)
    return [] if profile_tags.blank?
    person.environment.communities.
    select("profiles.*, suggestions.count AS common_count").
    joins("
      INNER JOIN (
        SELECT results.profiles_id AS profiles_id, count(results.profiles_id) FROM (
          SELECT DISTINCT tags.id, profiles.id AS profiles_id FROM profiles
          INNER JOIN articles ON articles.profile_id = profiles.id
          INNER JOIN taggings ON taggings.taggable_id = articles.id AND taggings.context = ('tags') AND taggings.taggable_type = 'Article'
          INNER JOIN tags ON tags.id = taggings.tag_id
          WHERE (tags.id IN (#{profile_tags.join(',')}) AND profiles.id != #{person.id})) AS results
        GROUP BY results.profiles_id
        HAVING count(results.profiles_id) >= #{COMMON_TAGS})
      AS suggestions ON profiles.id = suggestions.profiles_id")
  end

  def disable
    self.enabled = false
    self.save!
    self.class.generate_profile_suggestions(self.person)
  end

  def self.generate_all_profile_suggestions
    Delayed::Job.enqueue(ProfileSuggestion::GenerateAllJob.new) unless ProfileSuggestion::GenerateAllJob.exists?
  end

  def self.generate_profile_suggestions(person, force = false)
    return if person.profile_suggestions.enabled.count >= MIN_LIMIT && !force
    Delayed::Job.enqueue ProfileSuggestionsJob.new(person.id) unless ProfileSuggestionsJob.exists?(person.id)
  end

  class GenerateAllJob
    def self.exists?
      Delayed::Job.by_handler("--- !ruby/object:ProfileSuggestion::GenerateAllJob {}\n").count > 0
    end

    def perform
      Person.find_each {|person| ProfileSuggestion.generate_profile_suggestions(person) }
    end
  end

end
