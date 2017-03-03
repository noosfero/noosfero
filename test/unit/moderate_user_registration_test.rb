# encoding: UTF-8
require_relative "../test_helper"

class ModerateUserRegistrationTest < ActiveSupport::TestCase
  fixtures :users, :environments

  def test_should_on_perform_activate_user
    user = User.new(:login => 'lalala', :email => 'lalala@example.com', :password => 'test', :password_confirmation => 'test')
    user.save!
    environment = Environment.default
    t= ModerateUserRegistration.new
    t.user_id = user.id
    t.name = user.name
    t.author_name = user.name
    t.email = user.email
    t.target= environment
    t.save!
    refute user.activated?
    t.perform
    assert environment.users.find_by(id: user.id).activated?
  end

  should 'return the names of the custom fields' do
    person_custom_field = CustomField.create(:name => "registration_reason", :format=>"string", :default_value => "because i want to", :customized_type=>"Person", :active => true, :environment => Environment.default, :moderation_task => true, :required => true)
    user = User.new(:login => 'lalala', :email => 'lalala@example.com', :password => 'test', :password_confirmation => 'test')
    user.save!
    p1 = user.person
    p1.custom_values = {"registration_reason" => "I want to send my TCC"}
    p1.save!
    p1.reload
    task = ModerateUserRegistration.create!(:requestor => p1, :name => "great_person", :email => "alo@alo.alo", :target => Environment.default)
    task.save

    assert_match /registration_reason/, task.target_custom_fields
    assert_match /I want to send my TCC/, task.target_custom_fields
  end
end
