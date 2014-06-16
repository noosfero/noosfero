require File.dirname(__FILE__) + '/../test_helper'

class NotifyActivityToProfilesJobTest < ActiveSupport::TestCase

  should 'create job on user creation' do
    user = new_user :login => 'test1'
    job = YAML.load(Delayed::Job.last.handler)
    assert_kind_of UserActivationJob, job
    assert_equal user.id, job.user_id
    process_delayed_job_queue
  end

  should 'destroy user if not activated' do
    user = new_user :login => 'test2'
    job = UserActivationJob.new(user.id)
    assert_difference 'User.count', -1 do
      job.perform
      process_delayed_job_queue
    end
  end

  should 'not destroy user if activated' do
    user = new_user :login => 'test3'
    user.activate
    job = UserActivationJob.new(user.id)
    assert_no_difference 'User.count' do
      job.perform
      process_delayed_job_queue
    end
  end

  protected
    def new_user(options = {})
      user = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
      user.save
      user
    end

end
