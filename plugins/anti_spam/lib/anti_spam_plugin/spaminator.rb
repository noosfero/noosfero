require 'benchmark'

class AntiSpamPlugin::Spaminator

  class << self
    def run(environment)
      instance = new(environment)
      instance.run
    end

    def benchmark(environment)
      puts Benchmark.measure { run(environment) }
    end
  end


  def initialize(environment)
    @environment = environment
  end

  def run
    start_time = Time.now

    process_all_comments
    process_all_people
    process_people_without_network

    finish(start_time)
  end

  protected

  def finish(start_time)
    @environment.settings[:spaminator_last_run] = start_time
    @environment.save!
  end

  def conditions(table)
    last_run = @environment.settings[:spaminator_last_run]
    if last_run
      ["profiles.environment_id = ? AND #{table}.created_at > ?", @environment.id, last_run]
    else
      [ "profiles.environment_id = ?", @environment.id]
    end
  end

  def process_all_comments
    puts 'Processing comments ...'
    i = 0
    comments = Comment.joins("JOIN articles ON (comments.source_id = articles.id AND comments.source_type = 'Article') JOIN profiles ON (profiles.id = articles.profile_id)").where(conditions(:comments))
    total = comments.count
    comments.find_each do |comment|
      puts "Comment #{i += 1}/#{total} (#{100*i/total}%)"
      process_comment(comment)
    end
  end

  def process_all_people
    puts 'Processing people ...'
    i = 0
    people = Person.where(conditions(:profiles))
    total = people.count
    people.find_each do |person|
      puts "Person #{i += 1}/#{total} (#{100*i/total}%)"
      process_person(person)
    end
  end

  def process_comment(comment)
    comment.check_for_spam

    # TODO several comments with the same content:
    #   → disable author
    #   → mark all of them as spam

    # TODO check comments that contains URL's
  end

  def process_person(person)
    # person is author of more than 2 comments marked as spam
    #   → burn
    #
    number_of_spam_comments = Comment.spam.where(author_id => person.id).count
    if number_of_spam_comments > 2
      mark_as_spammer(person)
    end
  end

  def process_people_without_network
    # people who signed up more than one month ago, have no friends and <= 1
    # communities
    #
    #   → burn
    #   → mark their comments as spam
    #
    Person.where(:environment_id => @environment.id).where(['created_at < ?', Time.now - 1.month]).find_each do |person|
      # TODO progress indicator - see process_all_people above
      number_of_friends = person.friends.count
      number_of_communities = person.communities.count
      if number_of_friends == 0 && number_of_communities <= 1
        mark_as_spammer(person)
        Comment.where(:author_id => person.id).find_each do |comment|
          comment.spam!
        end
      end
    end
  end

  def mark_as_spammer(person)
    # FIXME create an AbuseComplaint and finish instead of calling
    # Person#disable directly
    person.disable
  end

end
