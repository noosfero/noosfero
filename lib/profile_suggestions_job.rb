class ProfileSuggestionsJob < Struct.new(:person_id)

  def self.exists?(person_id)
    !find(person_id).empty?
  end

  def self.find(person_id)
    Delayed::Job.by_handler("--- !ruby/struct:ProfileSuggestionsJob\nperson_id: #{person_id}\n")
  end

  def perform
    logger = Delayed::Worker.logger
    begin
      person = Person.find(person_id)
      ProfileSuggestion.calculate_suggestions(person)
      UserMailer.profiles_suggestions_email(person).deliver if person.email_suggestions
    rescue Exception => exception
      logger.error("Error with suggestions for person ID %d: %s" % [person_id, exception.to_s])
    end
  end

end
