require 'test_helper'
require 'rails/performance_test_help'

class UserTest < ActionDispatch::PerformanceTest

  attr_reader :environment

  def setup
    @environment = Environment.default
    @environment.disable('skip_new_user_email_confirmation')

    @environment.person_templates.destroy_all
    user = User.create!(:login => SecureRandom.uuid, :email => 'test@test.com', :password => 'test', :password_confirmation => 'test')
    user.person.update_attribute(:is_template, true)
    user.person.articles.destroy_all
    user.person.boxes.destroy_all

    @environment.person_default_template = user.person
    @environment.save!
  end

  def test_user_creation_without_confirmation
    User.benchmark("Creating user") do
      user = User.create!(:login => 'changetest', :password => 'test', :password_confirmation => 'test', :email => 'changetest@example.com', :environment => environment)
    end
  end

end
