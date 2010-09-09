require File.dirname(__FILE__) + '/../test_helper'

class MailingJobTest < ActiveSupport::TestCase

  def setup
    @environment = fast_create(Environment)
    @person_1 = create_user('user_one', :environment_id => @environment.id).person
    create_user('user_two', :environment_id => @environment.id)
  end
  attr_reader :environment

  should 'create delayed job' do
    assert_difference Delayed::Job, :count, 1 do
      mailing = EnvironmentMailing.create(:source_id => environment.id, :subject => 'Hello', :body => 'We have some news', :person => @person_1)
    end
  end

  should 'change locale according to the locale informed' do
    mailing = EnvironmentMailing.create(:source_id => environment.id, :subject => 'Hello', :body => 'We have some news', :locale => 'pt', :person => @person_1)
    Noosfero.expects(:with_locale).with('pt')
    process_delayed_job_queue
  end
end
