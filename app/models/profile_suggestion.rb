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

  RULES = %w[
    friends_of_friends_with_common_friends
    people_with_common_communities
    people_with_common_tags
    communities_with_common_friends
    communities_with_common_tags
  ]

  # Number of suggestions
  N_SUGGESTIONS = 30

  # Number max of attempts
  MAX_ATTEMPTS = N_SUGGESTIONS * 2

  # Number of friends in common
  COMMON_FRIENDS = 2

  # Number of communities in common
  COMMON_COMMUNITIES = 1

  # Number of friends in common
  COMMON_TAGS = 2

  def self.friends_of_friends_with_common_friends(person)
    person_attempts = 0
    person_friends = person.friends
    person_friends.each do |friend|
      friend.friends.includes.each do |friend_of_friend|
        person_attempts += 1
        return unless person.profile_suggestions.count < N_SUGGESTIONS && person_attempts < MAX_ATTEMPTS
        unless friend_of_friend == person || friend_of_friend.is_a_friend?(person) || person.already_request_friendship?(friend_of_friend)
          common_friends = friend_of_friend.friends & person_friends
          if common_friends.size >= COMMON_FRIENDS
            person.profile_suggestions.create(:suggestion => friend_of_friend, :common_friends => common_friends.size)
          end
        end
      end
    end
  end

  def self.people_with_common_communities(person)
    person_attempts = 0
    person_communities = person.communities
    person_communities.each do |community|
      community.members.each do |member|
        person_attempts += 1
        return unless person.profile_suggestions.count < N_SUGGESTIONS && person_attempts < MAX_ATTEMPTS
        unless member == person || member.is_a_friend?(person) || person.already_request_friendship?(member)
          common_communities = person_communities & member.communities
          if common_communities.size >= COMMON_COMMUNITIES
            person.profile_suggestions.create(:suggestion => member, :common_communities => common_communities.size)
          end
        end
      end
    end
  end

  def self.people_with_common_tags(person)
    person_attempts = 0
    tags = person.article_tags.keys
    tags.each do |tag|
      person_attempts += 1
      return unless person.profile_suggestions.count < N_SUGGESTIONS && person_attempts < MAX_ATTEMPTS
      tagged_content = ActsAsTaggableOn::Tagging.includes(:taggable).where(:tag_id => ActsAsTaggableOn::Tag.find_by_name(tag))
      tagged_content.each do |tg|
        author = tg.taggable.created_by
        unless author.nil? || author == person || author.is_a_friend?(person) || person.already_request_friendship?(author)
          common_tags = tags & author.article_tags.keys
          if common_tags.size >= COMMON_TAGS
            person.profile_suggestions.create(:suggestion => author, :common_tags => common_tags.size)
          end
        end
      end
    end
  end

  def self.communities_with_common_friends(person)
    community_attempts = 0
    person_friends = person.friends
    person_friends.each do |friend|
      friend.communities.each do |community|
        community_attempts += 1
        return unless person.profile_suggestions.count < N_SUGGESTIONS && community_attempts < MAX_ATTEMPTS
        unless person.is_member_of?(community) || community.already_request_membership?(person)
          common_friends = community.members & person.friends
          if common_friends.size >= COMMON_FRIENDS
            person.profile_suggestions.create(:suggestion => community, :common_friends => common_friends.size)
          end
        end
      end
    end
  end

  def self.communities_with_common_tags(person)
    community_attempts = 0
    tags = person.article_tags.keys
    tags.each do |tag|
      community_attempts += 1
      return unless person.profile_suggestions.count < N_SUGGESTIONS && community_attempts < MAX_ATTEMPTS
      tagged_content = ActsAsTaggableOn::Tagging.includes(:taggable).where(:tag_id => ActsAsTaggableOn::Tag.find_by_name(tag))
      tagged_content.each do |tg|
        profile = tg.taggable.profile
        unless !profile.community? || person.is_member_of?(profile) || profile.already_request_membership?(person)
          common_tags = tags & profile.article_tags.keys
          if common_tags.size >= COMMON_TAGS
            person.profile_suggestions.create(:suggestion => profile, :common_tags => common_tags.size)
          end
        end
      end
    end
  end

  def disable
    self.enabled = false
    self.save
  end

end
