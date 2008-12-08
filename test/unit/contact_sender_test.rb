require File.dirname(__FILE__) + '/../test_helper'

class ContactSenderTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  should 'be able to deliver mail' do
    ent = Enterprise.new(:name => 'my enterprise', :identifier => 'myent', :environment => Environment.default)
    ent.contact_email = 'contact@invalid.com'
    c = Contact.new(:dest => ent, :subject => 'hi molly')
    response = Contact::Sender.deliver_mail(c)
    assert_equal c.email, response.from
    assert_equal c.subject, response.subject
  end

  should 'deliver mail to contact_email' do
    ent = Enterprise.new(:name => 'my enterprise', :identifier => 'myent', :environment => Environment.default)
    ent.contact_email = 'contact@invalid.com'
    c = Contact.new(:dest => ent)
    response = Contact::Sender.deliver_mail(c)
    assert_includes response.to, c.dest.contact_email
  end
 
  should 'deliver mail to admins of enterprise' do
    admin = create_user('admin_test').person
    ent = Enterprise.create!(:name => 'my enterprise', :identifier => 'myent', :environment => Environment.default)
    ent.contact_email = 'contact@invalid.com'
    ent.add_admin(admin)
    assert ent.save!
    c = Contact.new(:dest => ent)
    response = Contact::Sender.deliver_mail(c)
    assert_includes response.to, admin.email
  end

  private

    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mail_sender/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end

end
