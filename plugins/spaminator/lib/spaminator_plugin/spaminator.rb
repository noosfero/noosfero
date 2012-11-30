require 'spaminator_plugin/mailer'

class SpaminatorPlugin::Spaminator

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
    @settings = Noosfero::Plugin::Settings.new(@environment, SpaminatorPlugin)
    @report = SpaminatorPlugin::Report.new(:environment => environment, 
                                           :total_people => Person.count,
                                           :total_comments => Comment.count)
  end

  def run
    start_time = Time.now

    process_all_comments
    process_all_people

    finish(start_time)
  end

  protected

  def finish(start_time)
    finish_report
    @settings.last_run = start_time
    @settings.save!
  end

  # TODO considering run everything always
  def on_environment
    [ "profiles.environment_id = ?", @environment.id]
  end

  def comments_to_process
    Comment.joins("JOIN articles ON (comments.source_id = articles.id AND comments.source_type = 'Article') JOIN profiles ON (profiles.id = articles.profile_id)").without_spam.where(on_environment)
  end

  def people_to_process
    Person.visible.non_abusers.where(on_environment)
  end

  def process_all_comments
    comments = comments_to_process
    total = comments.count
    pbar = ProgressBar.new("☢ Comments", total)
    comments.each do |comment|
      begin
        process_comment(comment)
      rescue
        register_fail(:comments, comment)
      end
      pbar.inc
    end
    @report.processed_comments = total
    pbar.finish
  end

  def process_all_people
    people = people_to_process
    total = people.count
    pbar = ProgressBar.new("☢ People", total)
    people.find_each do |person|
      process_person_by_comments(person)
      process_person_by_no_network(person)
      pbar.inc
    end
    @report.processed_people = total
    pbar.finish
  end

  def process_comment(comment)
    comment = Comment.find(comment.id)
    comment.check_for_spam
    @report.spams_by_content += 1 if comment.spam

    # TODO several comments with the same content:
    #   → disable author
    #   → mark all of them as spam

    # TODO check comments that contains URL's
  end

  def process_person_by_comments(person)
    # person is author of more than 2 comments marked as spam
    #   → mark as spammer
    #
    begin
      number_of_spam_comments = Comment.spam.where(:author_id => person.id).count
      if number_of_spam_comments > 2
        mark_as_spammer(person)
        @report.spammers_by_comments += 1
      end
    rescue
      register_fail(:people, person)
    end
  end

  def process_person_by_no_network(person)
    # person who signed up more than one month ago, have no friends and <= 1
    # communities
    #
    #   → disable the profile
    #   ? mark their comments as spam
    #
    if person.created_at < (Time.now - 1.month) &&
       person.friends.count == 0 &&
       person.communities.count <= 1
      begin
        disable_person(person)
        @report.spammers_by_no_network += 1
      rescue
        register_fail(:people, person)
      end
      Comment.where(:author_id => person.id).find_each do |comment|
        begin
          comment.spam!
          @report.spams_by_no_network += 1
        rescue
          register_fail(:comments, comment)
        end
      end
    end
  end

  def disable_person(person)
    if person.disable
      SpaminatorPlugin::Mailer.delay.deliver_inactive_person_notification(person)
    end
  end

  def mark_as_spammer(person)
    AbuseComplaint.create!(:reported => person).finish
  end

  def finish_report
    puts @report.details
    @report.save!
  end

  def register_fail(kind, failed)
    @report[:failed][kind.to_sym] << failed.id
  end
end

