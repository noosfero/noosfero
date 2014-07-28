class ProfileSuggestionsJob < Struct.new(:person_id)

  def perform
    begin
      person = Person.find(person_id)

      ProfileSuggestion::RULES.each do |rule|
        ProfileSuggestion.send(rule, person)
      end

      UserMailer.profiles_suggestions_email(person).deliver
    rescue Exception => exception
      Rails.logger.warn("Error with suggestions for person ID %d\n%s" % [person_id, exception.to_s])
    end
  end

end
