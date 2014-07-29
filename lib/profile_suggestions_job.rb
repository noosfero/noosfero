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

      ProfileSuggestion::RULES.each do |rule|
        ProfileSuggestion.send(rule, person)
      end
      UserMailer.profiles_suggestions_email(person).deliver
    rescue Exception => exception
      logger.warn("Error with suggestions for person ID %d: %s" % [person_id, exception.to_s])
    end
  end

end
