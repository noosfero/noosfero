require "test_helper"

class WatchedContentMailingTest < ActionDispatch::IntegrationTest

  def setup
    Environment.default.enable_plugin(MailingListPlugin)
    @profile = fast_create(Profile)
    @forum = fast_create(Forum, profile_id: @profile.id)

    @profile_settings = Noosfero::Plugin::Settings.new(@profile, MailingListPlugin)
    @forum_metadata = Noosfero::Plugin::Metadata.new(@forum, MailingListPlugin)

    client = mock
    client.stubs(:group_list_email).returns('grouplist@mail.com')
    MailingListPlugin::Client.stubs(:new).returns(client)
    Noosfero::Plugin::Settings.any_instance.stubs(:administrator_email)
                              .returns('admin@mail.com')
  end

  should 'send mail if list is enabled and blog is watched' do
    @profile_settings.enabled = true; @profile_settings.save!
    @forum_metadata.watched = true; @forum_metadata.save!
    author = create_user.person

    assert_difference 'ActionMailer::Base.deliveries.count' do
      a = Article.create(name: 'new', body: 'An article', author: author,
                         profile: @profile, parent: @forum)
      process_delayed_job_queue

      mail = ActionMailer::Base.deliveries.last
      assert_match /#{a.body}/, mail.html_part.body.raw_source
      assert_match /admin@mail.com/, mail.from.to_s
      assert_match /grouplist@mail.com/, mail.to.to_s
    end
  end

  should 'not send mail if the list is not enabled' do
    @profile_settings.enabled = false; @profile_settings.save!
    @forum_metadata.watched = true; @forum_metadata.save!

    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      Article.create(name: 'new', profile: @profile, parent: @forum)
      process_delayed_job_queue
    end
  end

  should 'not send mail if the blog is not watchde' do
    @profile_settings.enabled = true; @profile_settings.save!
    @forum_metadata.watched = false; @forum_metadata.save!

    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      Article.create(name: 'new', profile: @profile, parent: @forum)
      process_delayed_job_queue
    end
  end

  should 'not send mail if the article does not have a parent' do
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      Article.create(name: 'new', profile: @profile)
      process_delayed_job_queue
    end
  end

end
