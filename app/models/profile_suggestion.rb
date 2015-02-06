class ProfileSuggestion < ActiveRecord::Base
  belongs_to :person
  belongs_to :suggestion, :class_name => 'Profile', :foreign_key => :suggestion_id

  attr_accessible :person, :suggestion, :suggestion_type, :categories, :enabled

  has_many :suggestion_connections, :foreign_key => 'suggestion_id'
  has_many :profile_connections, :through => :suggestion_connections, :source => :connection, :source_type => 'Profile'
  has_many :tag_connections, :through => :suggestion_connections, :source => :connection, :source_type => 'ActsAsTaggableOn::Tag'

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
    :people_with_common_friends => ['menu-people', _('Friends in common')],
    :people_with_common_communities => ['menu-community',_('Communities in common')],
    :people_with_common_tags => ['edit', _('Tags in common')],
    :communities_with_common_friends => ['menu-people', _('Friends in common')],
    :communities_with_common_tags => ['edit', _('Tags in common')]
  }

  def category_icon(category)
    'icon-' + ProfileSuggestion::CATEGORIES[category][0]
  end

  def category_label(category)
    ProfileSuggestion::CATEGORIES[category][1]
  end

  RULES = {
    :people_with_common_communities => {
      :threshold => 2, :weight => 1, :connection => 'Profile'
    },
    :people_with_common_friends => {
      :threshold => 2, :weight => 1, :connection => 'Profile'
    },
    :people_with_common_tags => {
      :threshold => 2, :weight => 1, :connection => 'ActsAsTaggableOn::Tag'
    },
    :communities_with_common_friends => {
      :threshold => 2, :weight => 1, :connection => 'Profile'
    },
    :communities_with_common_tags => {
      :threshold => 2, :weight => 1, :connection => 'ActsAsTaggableOn::Tag'
    }
  }

  RULES.keys.each do |rule|
    settings_items rule
    attr_accessible rule
  end

  # Number of suggestions by rule
  N_SUGGESTIONS = 30

  # Minimum number of suggestions
  MIN_LIMIT = 10

  def self.profile_id(rule)
    "#{rule}_profile_id"
  end

  def self.connections(rule)
    "#{rule}_connections"
  end

  def self.counter(rule)
    "#{rule}_count"
  end

  # If you are about to rewrite the following sql queries, think twice. After
  # that make sure that whatever you are writing to replace it should be faster
  # than how it is now. Yes, sqls are ugly but are fast! And fast is what we
  # need here.
  #
  # The logic behind this code is to produce a table somewhat like this:
  # profile_id | rule1_count | rule1_connections | rule2_count | rule2_connections | ... | score |
  #     12     |      2      |      {32,54}      |      3      |     {8,22,27}     | ... |   13  |
  #     13     |      4      |   {3,12,32,54}    |      2      |      {11,24}      | ... |   15  |
  #     14     |             |                   |      2      |      {44,56}      | ... |   17  |
  #                                        ...
  #                                        ...
  #
  # This table has the suggested profile id and the count and connections of
  # each rule that made this profile be suggested. Each suggestion has a score
  # associated based on the rules' counts and rules' weights.
  #
  # From this table, we can sort suggestions by the score and save a small
  # amount of them in the database. At this moment we also register the
  # connections of each suggestion.

  def self.calculate_suggestions(person)
    suggested_profiles = all_suggestions(person)
    return if suggested_profiles.nil?

    already_suggested_profiles = person.profile_suggestions.map(&:suggestion_id).join(',')
    suggested_profiles = suggested_profiles.where("profiles.id NOT IN (#{already_suggested_profiles})") if already_suggested_profiles.present?
    #TODO suggested_profiles = suggested_profiles.order('score DESC')
    suggested_profiles = suggested_profiles.limit(N_SUGGESTIONS)
    return if suggested_profiles.blank?

    suggested_profiles.each do |suggested_profile|
      suggestion = person.profile_suggestions.find_or_initialize_by_suggestion_id(suggested_profile.id)
      RULES.each do |rule, options|
        begin
          value = suggested_profile.send("#{rule}_count").to_i
        rescue NoMethodError
          next
        end
        connections = suggested_profile.send("#{rule}_connections")
        if connections.present?
          connections = connections[1..-2].split(',')
        else
          connections = []
        end
        suggestion.send("#{rule}=", value)
        connections.each do |connection_id|
          next if SuggestionConnection.where(:suggestion_id => suggestion.id, :connection_id => connection_id, :connection_type => options[:connection]).present?
           SuggestionConnection.create!(:suggestion => suggestion, :connection_id => connection_id, :connection_type => options[:connection])
        end
        suggestion.score += value * options[:weight]
      end
      suggestion.save!
    end
  end

  def self.people_with_common_friends(person)
    person_friends = person.friends.map(&:id)
    rule = "people_with_common_friends"
    return if person_friends.blank?
    "SELECT person_id as #{profile_id(rule)},
            array_agg(friend_id) as #{connections(rule)},
            count(person_id) as #{counter(rule)}
     FROM friendships WHERE friend_id IN (#{person_friends.join(',')})
     AND person_id NOT IN (#{(person_friends << person.id).join(',')})
     GROUP BY person_id"
  end

  def self.people_with_common_communities(person)
    person_communities = person.communities.map(&:id)
    rule = "people_with_common_communities"
    return if person_communities.blank?
    "SELECT common_members.accessor_id as #{profile_id(rule)},
            array_agg(common_members.resource_id) as #{connections(rule)},
            count(common_members.accessor_id) as #{counter(rule)}
     FROM
       (SELECT DISTINCT accessor_id, resource_id FROM
       role_assignments WHERE role_assignments.resource_id IN (#{person_communities.join(',')}) AND
       role_assignments.accessor_id != #{person.id} AND role_assignments.resource_type = 'Profile' AND
       role_assignments.accessor_type = 'Profile') AS common_members
     GROUP BY common_members.accessor_id"
  end

  def self.people_with_common_tags(person)
    profile_tags = person.articles.select('tags.id').joins(:tags).map(&:id)
    rule = "people_with_common_tags"
    return if profile_tags.blank?
    "SELECT results.profiles_id as #{profile_id(rule)},
            array_agg(results.tags_id) as #{connections(rule)},
            count(results.profiles_id) as #{counter(rule)}
     FROM (
       SELECT DISTINCT tags.id as tags_id, profiles.id as profiles_id FROM profiles
       INNER JOIN articles ON articles.profile_id = profiles.id
       INNER JOIN taggings ON taggings.taggable_id = articles.id AND taggings.context = ('tags') AND taggings.taggable_type = 'Article'
       INNER JOIN tags ON tags.id = taggings.tag_id
       WHERE (tags.id in (#{profile_tags.join(',')}) AND profiles.id != #{person.id})) AS results
     GROUP BY results.profiles_id"
  end

  def self.communities_with_common_friends(person)
    person_friends = person.friends.map(&:id)
    rule = "communities_with_common_friends"
    return if person_friends.blank?
    "SELECT common_communities.resource_id as #{profile_id(rule)},
            array_agg(common_communities.accessor_id) as #{connections(rule)},
            count(common_communities.resource_id) as #{counter(rule)}
     FROM
       (SELECT DISTINCT accessor_id, resource_id FROM
       role_assignments WHERE role_assignments.accessor_id IN (#{person_friends.join(',')}) AND
       role_assignments.accessor_id != #{person.id} AND role_assignments.resource_type = 'Profile' AND
       role_assignments.accessor_type = 'Profile') AS common_communities
     GROUP BY common_communities.resource_id"
  end

  def self.communities_with_common_tags(person)
    profile_tags = person.articles.select('tags.id').joins(:tags).map(&:id)
    rule = "communities_with_common_tags"
    return if profile_tags.blank?
    "SELECT results.profiles_id as #{profile_id(rule)},
            array_agg(results.tags_id) as #{connections(rule)},
            count(results.profiles_id) as #{counter(rule)}
     FROM
       (SELECT DISTINCT tags.id as tags_id, profiles.id AS profiles_id FROM profiles
       INNER JOIN articles ON articles.profile_id = profiles.id
       INNER JOIN taggings ON taggings.taggable_id = articles.id AND taggings.context = ('tags') AND taggings.taggable_type = 'Article'
       INNER JOIN tags ON tags.id = taggings.tag_id
       WHERE (tags.id IN (#{profile_tags.join(',')}) AND profiles.id != #{person.id})) AS results
     GROUP BY results.profiles_id"
  end

  def self.all_suggestions(person)
    select_string = ["profiles.*"]
    suggestions_join = []
    where_string = []
    valid_rules = []
    previous_rule = nil
    join_column = nil
    RULES.each do |rule, options|
      rule_select = self.send(rule, person)
      next if !rule_select.present?

      valid_rules << rule
      select_string << "suggestions.#{counter(rule)} as #{counter(rule)}, suggestions.#{connections(rule)} as #{connections(rule)}"
      where_string << "#{counter(rule)} >= #{options[:threshold]}"
      rule_select = "
        (SELECT profiles.id as #{profile_id(rule)},
                #{rule}_sub.#{counter(rule)} as #{counter(rule)},
                #{rule}_sub.#{connections(rule)} as #{connections(rule)}
        FROM profiles
        LEFT OUTER JOIN (#{rule_select}) as #{rule}_sub
        ON profiles.id = #{rule}_sub.#{profile_id(rule)}) AS #{rule}"

      if previous_rule.nil?
        result = rule_select
      else
        result = "INNER JOIN #{rule_select}
         ON #{previous_rule}.#{profile_id(previous_rule)} = #{rule}.#{profile_id(rule)}"
      end
      previous_rule = rule
      suggestions_join << result
    end

    return if valid_rules.blank?

    select_string = select_string.compact.join(',')
    join_string = "INNER JOIN (SELECT * FROM #{suggestions_join.compact.join(' ')}) AS suggestions ON profiles.id = suggestions.#{profile_id(valid_rules.first)}"
    where_string = where_string.compact.join(' OR ')

    person.environment.profiles.
      select(select_string).
      joins(join_string).
      where(where_string)
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
