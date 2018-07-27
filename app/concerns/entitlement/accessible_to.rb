module Entitlement::AccessibleTo
  def self.included(base)
    base.class_eval do
      scope :accessible_to, lambda { |user|
        # Visitors
        return where("#{table_name}.access = #{Entitlement::Levels.levels[:visitors]}") if user.nil?

        # Environment administrators can access anything
        return if user.environment.admins.include?(user)

        # This score_table is in the following format:
        #
        # | id | score |
        # | 1  |  10   |
        # | 5  |  10   |
        # | 8  |  25   |
        #
        # The score is the greatest access level the user accessing the object has
        # based on his relations with it. Objects with access requirements lower or
        # equal to level "users" are not included in this view for performance
        # reasons.
        #
        # Conditions for the object to be accessible are:
        #   * The object's owner is the user OR
        #   * The object has an access requirement lower or equal to level "users" OR
        #   * The user has an access level higher than the object requires.

        joins("left join #{score_table(user)}").
        where("
          #{profile_id_column} = #{user.id} OR
          #{table_name}.access <= #{Entitlement::Levels.levels[:users]} OR
          #{table_name}.access <= score")
      }
    end
  end
end
