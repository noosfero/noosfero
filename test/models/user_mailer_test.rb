require_relative "../test_helper"

class UserMailerTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + "/../fixtures"
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  should "deliver activation email notify" do
    assert_difference "ActionMailer::Base.deliveries.size" do
      u = create_user("some-user")
      UserMailer.activation_email_notify(u).deliver
    end
  end

  should "deliver profiles suggestions email" do
    person = create_user("some-user").person
    ProfileSuggestion.create!(person: person, suggestion: fast_create(Person))
    email = UserMailer.profiles_suggestions_email(person).deliver
    assert_match /profile\/some-user\/friends\/suggest/, email.body.to_s
  end

  should "deliver activation code email" do
    assert_difference "ActionMailer::Base.deliveries.size" do
      u = create_user("some-user")
      UserMailer.activation_code(u).deliver
    end
  end

  should "deliver activation code email with template" do
    EmailTemplate.create!(template_type: :user_activation, name: "template1", subject: "activation template subject", body: "activation template body", owner: Environment.default)
    assert_difference "ActionMailer::Base.deliveries.size" do
      u = create_user("some-user")
      UserMailer.activation_code(u).deliver
    end
    mail = ActionMailer::Base.deliveries.last
    assert_equal "activation template subject", mail.subject.to_s
    assert_equal "activation template body", mail.body.to_s
  end

  should "include activation code and link on activation mail" do
    user = create_user_full
    UserMailer.activation_code(user).deliver
    mail = ActionMailer::Base.deliveries.last

    assert_match /\/activate\?activation_token=#{user.activation_code}/,
                 mail.body.to_s
    assert_match /#{user.short_activation_code}/i, mail.body.to_s
  end

  should "not leak template params into activation email" do
    EmailTemplate.create!(template_type: :user_activation, name: "template1", subject: "activation template subject", body: "activation template body", owner: Environment.default)
    assert_difference "ActionMailer::Base.deliveries.size" do
      u = create_user("some-user")
      UserMailer.activation_code(u).deliver
    end
    mail = ActionMailer::Base.deliveries.last
    assert_nil mail["template-params"]
  end

  private

    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mail_sender/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
