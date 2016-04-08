require_dependency 'profile_suggestion'

class ProfileSuggestion

  CATEGORIES.merge!({:common_classroom => _('Classroom in common')})

  RULES[:people_with_common_classroom] = {
    :threshold => 2, :weight => 1, :connection => 'Profile'
  }
  def self.people_with_common_classroom(person)
    usp_id = person.usp_id
    return if usp_id.nil?
    person_attempts = 0
    StoaPlugin::UspAlunoTurmaGrad.classrooms_from_person(usp_id).each do |classroom|
      person_attempts += 1
      return unless person.profile_suggestions.count < N_SUGGESTIONS && person_attempts < MAX_ATTEMPTS
      StoaPlugin::UspAlunoTurmaGrad.where(codtur: classroom.codtur).each do |same_class|
        classmate = Person.find_by usp_id: same_class.codpes
        unless classmate.nil? || classmate == person || classmate.is_a_friend?(person) || person.already_request_friendship?(classmate)
          suggestion = person.profile_suggestions.find_or_initialize_by_suggestion_id(classmate.id)
          suggestion.common_classroom = 1
          suggestion.save
        end
      end
    end
  end

  def self.people_with_common_discipline(person)
    person_attempts = 0
    person_attempts += 1
    return unless person.profile_suggestions.count < N_SUGGESTIONS && person_attempts < MAX_ATTEMPTS
  end

end
