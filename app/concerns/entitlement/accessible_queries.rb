module Entitlement::AccessibleQueries
  def friendship_conditions(user)
    Entitlement::Checks::Profile::Friend.filter_condition(user)
  end

  def membership_conditions(user)
    [
      Entitlement::Checks::Profile::Administrator,
      Entitlement::Checks::Profile::ViewPrivateContent,
      Entitlement::Checks::Profile::Member,
    ].map { |check| check.filter_condition(user) }.join('')
  end

  def score_query(kind, user)
<<-eos
  (select id,
    max(case
#{self.send(kind + '_conditions', user)}      else #{Entitlement::Levels.levels[:users]}
    end)
    as #{kind}_score from #{self.send(kind + '_score_table')} group by id
  )
eos
  end

  def score_columns
    score_kinds.map do |kind|
      "#{kind}.#{kind}_score"
    end.join(', ')
  end

  def score_join(user)
    previous = nil
    score_kinds.map do |kind|
      result = "#{score_query(kind, user)}  as #{kind}"
      if previous.present?
        result += " on #{previous}.id = #{kind}.id"
      end
      previous = kind
      result
    end.join(" inner join\n")
  end

  def score_table(user)
<<-eos
(select #{score_kinds.first}.id, greatest(#{score_columns}) as score from
#{score_join(user)}
) as r on r.id = #{table_name}.id
eos
  end
end

