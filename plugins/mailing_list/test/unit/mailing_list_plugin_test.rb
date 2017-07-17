require 'test_helper'

class MailingListPluginTest < ActiveSupport::TestCase
  def setup
    environment = Environment.default
    environment.enable_plugin('MailingListPlugin')
    Noosfero::Plugin.stubs(:all).returns(['MailingListPlugin'])
  end

  should 'subscribe user in the mailing list after joining the group' do
    client = mock
    MailingListPlugin::Client.stubs(:new).returns(client)
    group = fast_create(Organization)
    person = fast_create(Person)
    client.expects(:subscribe_person_on_group_list).with(person, group)
    group.add_member(person)
  end

  should 'unsubscribe user in the mailing list after leaving the group' do
    client = mock
    MailingListPlugin::Client.stubs(:new).returns(client)
    group = fast_create(Organization)
    person = fast_create(Person)
    client.stubs(:subscribe_person_on_group_list)
    group.add_member(person)
    client.expects(:unsubscribe_person_from_group_list).with(person, group)
    group.remove_member(person)
  end

  should 'watch article creation' do
    parent = fast_create(Article)
    MailingListPlugin.any_instance.expects(:watched_content_creation)
    Article.create!(name: 'My Article', parent: parent, profile: fast_create(Profile))
  end

  should 'watch comment creation' do
    parent = fast_create(Article)
    article = Article.create!(name: 'My Article', parent: parent, profile: fast_create(Profile))
    MailingListPlugin.any_instance.expects(:watched_content_creation)
    Comment.create!(body: 'My Comment', source: article, author: fast_create(Person))
  end

  should 'send email of article' do
    reply_email = mock
    reply_email.expects(:deliver)
    MailingListPlugin::Mailer.expects(:reply_email).returns(reply_email)

    profile = fast_create(Profile)
    profile_metadata = Noosfero::Plugin::Settings.new profile, MailingListPlugin
    profile_metadata.enabled = true
    profile_metadata.save!

    parent = fast_create(Article, profile_id: profile.id)
    parent_metadata = Noosfero::Plugin::Metadata.new parent, MailingListPlugin
    parent_metadata.watched = true
    parent_metadata.save!

    article = Article.create!(name: 'My Article', parent: parent, profile: profile)
    content_metadata = Noosfero::Plugin::Metadata.new article, MailingListPlugin

    assert content_metadata.uuid.present?
  end

  should 'send email of comment' do
    reply_email = mock
    reply_email.expects(:deliver).twice
    MailingListPlugin::Mailer.expects(:reply_email).twice.returns(reply_email)

    profile = fast_create(Profile)
    profile_metadata = Noosfero::Plugin::Settings.new profile, MailingListPlugin
    profile_metadata.enabled = true
    profile_metadata.save!

    parent = fast_create(Article, profile_id: profile.id)
    parent_metadata = Noosfero::Plugin::Metadata.new parent, MailingListPlugin
    parent_metadata.watched = true
    parent_metadata.save!

    article = Article.create!(name: 'My Article', parent: parent, profile: profile)
    comment = Comment.create!(body: 'My Comment', source: article, author: fast_create(Person))
    content_metadata = Noosfero::Plugin::Metadata.new comment, MailingListPlugin

    assert content_metadata.uuid.present?
  end

  should 'not send email if article references no parent article' do
    MailingListPlugin::Mailer.expects(:reply_email).never
    article = Article.create!(name: 'My Article', profile: fast_create(Profile))
    content_metadata = Noosfero::Plugin::Metadata.new article, MailingListPlugin

    assert_nil content_metadata.uuid
  end

  should 'not send email if comment references no parent article' do
    MailingListPlugin::Mailer.expects(:reply_email).never
    article = Article.create!(name: 'My Article', profile: fast_create(Profile))
    comment = Comment.create!(body: 'My Comment', source: article, author: fast_create(Person))
    content_metadata = Noosfero::Plugin::Metadata.new comment, MailingListPlugin

    assert_nil content_metadata.uuid
  end

  should 'not send email if article belongs to a profile that is not enabled' do
    MailingListPlugin::Mailer.expects(:reply_email).never

    profile = fast_create(Profile)
    profile_metadata = Noosfero::Plugin::Settings.new profile, MailingListPlugin
    profile_metadata.enabled = false
    profile_metadata.save!

    parent = fast_create(Article, profile_id: profile.id)
    parent_metadata = Noosfero::Plugin::Metadata.new parent, MailingListPlugin
    parent_metadata.watched = true
    parent_metadata.save!

    article = Article.create!(name: 'My Article', parent: parent, profile: profile)
    content_metadata = Noosfero::Plugin::Metadata.new article, MailingListPlugin

    assert_nil content_metadata.uuid
  end

  should 'not send email if comment belongs to a profile that is not enabled' do
    MailingListPlugin::Mailer.expects(:reply_email).never

    profile = fast_create(Profile)
    profile_metadata = Noosfero::Plugin::Settings.new profile, MailingListPlugin
    profile_metadata.enabled = false
    profile_metadata.save!

    parent = fast_create(Article, profile_id: profile.id)
    parent_metadata = Noosfero::Plugin::Metadata.new parent, MailingListPlugin
    parent_metadata.watched = true
    parent_metadata.save!

    article = Article.create!(name: 'My Article', parent: parent, profile: profile)
    comment = Comment.create!(body: 'My Comment', source: article, author: fast_create(Person))
    content_metadata = Noosfero::Plugin::Metadata.new comment, MailingListPlugin

    assert_nil content_metadata.uuid
  end

  should 'not send email if article belongs to a content that is not being watched' do
    MailingListPlugin::Mailer.expects(:reply_email).never


    profile = fast_create(Profile)
    profile_metadata = Noosfero::Plugin::Settings.new profile, MailingListPlugin
    profile_metadata.enabled = true
    profile_metadata.save!

    parent = fast_create(Article, profile_id: profile.id)
    parent_metadata = Noosfero::Plugin::Metadata.new parent, MailingListPlugin
    parent_metadata.watched = false
    parent_metadata.save!

    article = Article.create!(name: 'My Article', parent: parent, profile: profile)
    content_metadata = Noosfero::Plugin::Metadata.new article, MailingListPlugin

    assert_nil content_metadata.uuid
  end

  should 'not send email if comment belongs to a content that is not being watched' do
    MailingListPlugin::Mailer.expects(:reply_email).never

    profile = fast_create(Profile)
    profile_metadata = Noosfero::Plugin::Settings.new profile, MailingListPlugin
    profile_metadata.enabled = true
    profile_metadata.save!

    parent = fast_create(Article, profile_id: profile.id)
    parent_metadata = Noosfero::Plugin::Metadata.new parent, MailingListPlugin
    parent_metadata.watched = false
    parent_metadata.save!

    article = Article.create!(name: 'My Article', parent: parent, profile: profile)
    comment = Comment.create!(body: 'My Comment', source: article, author: fast_create(Person))
    content_metadata = Noosfero::Plugin::Metadata.new comment, MailingListPlugin

    assert_nil content_metadata.uuid
  end

  should 'send not email of comment which source article has no uuid' do
    MailingListPlugin::Mailer.expects(:reply_email).never

    profile = fast_create(Profile)
    profile_metadata = Noosfero::Plugin::Settings.new profile, MailingListPlugin
    profile_metadata.enabled = true
    profile_metadata.save!

    parent = fast_create(Article, profile_id: profile.id)
    parent_metadata = Noosfero::Plugin::Metadata.new parent, MailingListPlugin
    parent_metadata.watched = false
    parent_metadata.save!

    article = Article.create!(name: 'My Article', parent: parent, profile: profile)
    parent_metadata.watched = true
    parent_metadata.save!

    comment = Comment.create!(body: 'My Comment', source: article, author: fast_create(Person))
    content_metadata = Noosfero::Plugin::Metadata.new comment, MailingListPlugin

    assert_nil content_metadata.uuid
  end

  should 'send not email of comment which reply_of has no uuid' do
    MailingListPlugin::Mailer.expects(:reply_email).never

    profile = fast_create(Profile)
    profile_metadata = Noosfero::Plugin::Settings.new profile, MailingListPlugin
    profile_metadata.enabled = true
    profile_metadata.save!

    parent = fast_create(Article, profile_id: profile.id)
    parent_metadata = Noosfero::Plugin::Metadata.new parent, MailingListPlugin
    parent_metadata.watched = false
    parent_metadata.save!

    article = Article.create!(name: 'My Article', parent: parent, profile: profile)
    comment = Comment.create!(body: 'My Comment', source: article, author: fast_create(Person))
    parent_metadata.watched = true
    parent_metadata.save!

    reply = Comment.create!(body: 'My Comment Reply', source: article, author: fast_create(Person), reply_of_id: comment.id)
    content_metadata = Noosfero::Plugin::Metadata.new reply, MailingListPlugin

    assert_nil content_metadata.uuid
  end

#  should '' do
#  end
#
#  should '' do
#  end
end

