require 'test_helper'

class NewsletterPluginTest < ActiveSupport::TestCase

  def setup
    NewsletterPlugin::Newsletter.any_instance.stubs(:must_be_sent_today?).returns(true)
    NewsletterPlugin::Newsletter.any_instance.stubs(:has_posts_in_the_period?).returns(true)
  end

  should 'update newsletter send date only for enabled newsletters' do
    newsletter_enabled = NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment),
      :enabled => true,
      :subject => 'newsletter test',
      :person => fast_create(Person))

    newsletter_disabled = NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment),
      :enabled => false,
      :subject => 'newsletter test',
      :person => fast_create(Person))

    NewsletterPlugin.compile_and_send_newsletters

    newsletter_enabled.reload
    newsletter_disabled.reload

    assert_not_nil newsletter_enabled.last_send_at
    assert_nil newsletter_disabled.last_send_at
  end

  should 'create and schedule newsletter mailing if not moderated' do
    NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment),
      :enabled => true,
      :moderated => false,
      :subject => 'newsletter test',
      :person => fast_create(Person))

    assert_difference 'NewsletterPlugin::NewsletterMailing.count', 1 do
      NewsletterPlugin.compile_and_send_newsletters
    end

    assert_equal 0, NewsletterPlugin::ModerateNewsletter.count
  end

  should 'use same environment locale on mailing' do
    NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment, :default_language => 'pt_BR'),
      :enabled => true,
      :subject => 'newsletter test',
      :person => fast_create(Person))

    NewsletterPlugin.compile_and_send_newsletters
    assert_equal 'pt_BR', NewsletterPlugin::NewsletterMailing.last.locale
  end

  should 'create newsletter moderation task if newsletter is moderated' do
    adminuser = create_user.person
    Environment.any_instance.stubs(:admins).returns([adminuser])

    NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment),
      :enabled => true,
      :moderated => true,
      :subject => 'newsletter test',
      :person => fast_create(Person))

    assert_difference 'NewsletterPlugin::ModerateNewsletter.count', 1 do
      NewsletterPlugin.compile_and_send_newsletters
    end

    assert_equal 0, NewsletterPlugin::NewsletterMailing.count
  end

  should 'not create mailing if has no posts in the period' do
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment),
      :person => fast_create(Person),
      :enabled => true
    )
    NewsletterPlugin::Newsletter.any_instance.stubs(:must_be_sent_today?).returns(true)
    NewsletterPlugin::Newsletter.any_instance.stubs(:has_posts_in_the_period?).returns(false)
    assert_no_difference 'NewsletterPlugin::NewsletterMailing.count' do
      NewsletterPlugin.compile_and_send_newsletters
    end
  end

  should 'not create mailing if doesnt must be sent today' do
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment),
      :person => fast_create(Person),
      :enabled => true
    )
    NewsletterPlugin::Newsletter.any_instance.stubs(:must_be_sent_today?).returns(false)
    NewsletterPlugin::Newsletter.any_instance.stubs(:has_posts_in_the_period?).returns(true)
    assert_no_difference 'NewsletterPlugin::NewsletterMailing.count' do
      NewsletterPlugin.compile_and_send_newsletters
    end
  end

  should 'create mailing' do
    newsletter = NewsletterPlugin::Newsletter.create!(
      :environment => fast_create(Environment),
      :person => fast_create(Person),
      :enabled => true
    )
    assert_difference 'NewsletterPlugin::NewsletterMailing.count' do
      NewsletterPlugin.compile_and_send_newsletters
    end
  end

end
