module Entitlement::Checks::Article
  class Exception < Entitlement::Check
    alias :content :object

    def self.level
      Entitlement::Levels.levels[:self]
    end

    def self.filter_condition(user)
<<-eos
      when article_privacy_exceptions.person_id = #{user.id} then #{level}
eos
    end

    def entitles?(user)
      content.article_privacy_exceptions.include? (user)
    end
  end
end
