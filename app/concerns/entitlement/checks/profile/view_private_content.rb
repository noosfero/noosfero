module Entitlement::Checks::Profile
  class ViewPrivateContent < Entitlement::Check
    alias :profile :object

    def self.level
      Entitlement::Levels.levels[:self]
    end

    def self.filter_condition(user)
<<-eos
      when member_id = #{user.id} and permissions like '%view_private_content%' then #{level}
eos
    end

    def entitles?(user)
      user && user.has_permission?(:view_private_content, profile)
    end
  end
end
