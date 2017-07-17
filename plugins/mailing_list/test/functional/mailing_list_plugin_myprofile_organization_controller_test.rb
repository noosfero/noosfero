require 'test_helper'

class MailingListPluginMyprofileOrganizationControllerTest < ActionController::TestCase

  def setup
    @profile = fast_create(Organization)
    @member1 = create_user.person
    @member2 = create_user.person

    @profile.add_member(@member1)
    @profile.add_member(@member2)
    login_as(@member1.identifier)

    @client = mock
    @client.stubs(:login)
    Mail::Sympa.stubs(:new).returns(@client)
  end

  should 'list all members that are not templates if list exists' do
    template = fast_create(Person, is_template: true)
    @profile.add_member(template)
    list = mock
    list.stubs(:listAddress).returns("#{@profile.identifier}@example.org")
    @client.stubs(:complex_lists).returns([list])
    @client.stubs(:review).returns(['no_subscribers'])

    get :edit, profile: @profile.identifier
    assert_tag 'a', content: @member1.name, ancestor: { tag: 'table' }
    assert_tag 'a', content: @member2.name, ancestor: { tag: 'table' }
    assert_no_tag 'a', content: template.name, ancestor: { tag: 'table' }
  end

  should 'not render the members list if the list does not exist' do
    @client.stubs(:complex_lists).returns([])

    get :edit, profile: @profile.identifier
    assert_no_tag 'a', content: @member1.name, ancestor: { tag: 'table' }
    assert_no_tag 'a', content: @member2.name, ancestor: { tag: 'table' }
  end

  should 'update the profile settings' do
    list = mock
    list.stubs(:listAddress).returns("#{@profile.identifier}@example.org")
    @client.stubs(:complex_lists).returns([list])
    @client.stubs(:review).returns(['no_subscribers'])
    settings = Noosfero::Plugin::Settings.new(@profile, MailingListPlugin,
                                              enabled: true)
    settings.save!

    post :edit, profile: @profile.identifier,
         profile_settings: { enabled: false }, watched_contents: ''
    @profile.reload
    refute settings.enabled
  end

  should 'update the watched contents of the profile' do
    blog = fast_create(Blog, profile_id: @profile.id)
    forum1 = fast_create(Forum, profile_id: @profile.id)
    forum2 = fast_create(Forum, profile_id: @profile.id)
    Noosfero::Plugin::Metadata.new(blog, MailingListPlugin, watched: true).save!
    Noosfero::Plugin::Metadata.new(forum1, MailingListPlugin, watched: true).save!
    list = mock
    list.stubs(:listAddress).returns("#{@profile.identifier}@example.org")
    @client.stubs(:complex_lists).returns([list])
    @client.stubs(:review).returns(['no_subscribers'])

    contents = @profile.articles.with_plugin_metadata(MailingListPlugin,
                                                      { watched: true })
    assert_equivalent [blog, forum1], contents

    post :edit, profile: @profile.identifier,
                watched_contents: "#{blog.id},#{forum2.id}"
    contents = @profile.articles.with_plugin_metadata(MailingListPlugin,
                                                      { watched: true })
    assert_equivalent [blog, forum2], contents

    post :edit, profile: @profile.identifier, watched_contents: "#{forum1.id}"
    contents = @profile.articles.with_plugin_metadata(MailingListPlugin,
                                                      { watched: true })
    assert_equivalent [forum1], contents
  end

  should 'remove all watched contents' do
    blog = fast_create(Blog, profile_id: @profile.id)
    forum = fast_create(Forum, profile_id: @profile.id)
    Noosfero::Plugin::Metadata.new(blog, MailingListPlugin, watched: true).save!
    Noosfero::Plugin::Metadata.new(forum, MailingListPlugin, watched: true).save!

    list = mock
    list.stubs(:listAddress).returns("#{@profile.identifier}@example.org")
    @client.stubs(:complex_lists).returns([list])
    @client.stubs(:review).returns(['no_subscribers'])
    post :edit, profile: @profile.identifier, watched_contents: ''

    contents = @profile.articles.with_plugin_metadata(MailingListPlugin,
                                                      { watched: true })
    assert_equivalent [], contents
  end

  should 'return only not watched contents when searching' do
    blog = fast_create(Blog, profile_id: @profile.id)
    forum1 = fast_create(Forum, profile_id: @profile.id)
    forum2 = fast_create(Forum, profile_id: @profile.id)
    Noosfero::Plugin::Metadata.new(blog, MailingListPlugin, watched: false).save!
    Noosfero::Plugin::Metadata.new(forum1, MailingListPlugin, watched: false).save!
    Noosfero::Plugin::Metadata.new(forum2, MailingListPlugin, watched: true).save!

    get :search_content, profile: @profile.identifier, q: ''
    assert_match /#{blog.name}/, @response.body
    assert_match /#{forum1.name}/, @response.body
    assert_no_match /#{forum2.name}/, @response.body
  end

  should 'also return contents where watched metadata was not set' do
    # FIXME
  end

  should 'subscribe immediately if the user is an admin of the profile' do
    @client.stubs(:review).returns(['no_subscribers'])
    @client.expects(:add).once
    get :subscribe, profile: @profile.identifier, id: @member1.id
  end

  should 'subscribe if the user is not an admin but already requested' do
    t = MailingListPlugin::AcceptSubscription.new(target: @profile,
                                                  requestor: @member2)
    t.metadata['person_id'] = @member2.id
    t.save!

    @client.stubs(:review).returns(['no_subscribers'])
    @client.expects(:add).once
    get :subscribe, profile: @profile.identifier, id: @member2.id

    t.reload
    assert_equal Task::Status::FINISHED, t.status
  end

  should 'create a task if the user is not an admin and did not request yet' do
    assert_difference 'MailingListPlugin::SubscribeMember.count' do
      get :subscribe, profile: @profile.identifier, id: @member2.id
    end
  end

  should 'not subscribe if the user is already subscribed' do
    @client.stubs(:review).returns(@member1.email)
    @client.expects(:add).never
    get :subscribe, profile: @profile.identifier, id: @member1.id
  end

  should 'not subscribe or create task if the user was already invited' do
    t = MailingListPlugin::SubscribeMember.new(target: @member2,
                                               requestor: @member1)
    t.metadata['group_id'] = @member2.id
    t.save

    @client.expects(:add).never
    assert_no_difference 'MailingListPlugin::AcceptSubscription.count' do
      get :subscribe, profile: @profile.identifier, id: @member2.id
    end
  end

  should 'unsubscribe a member' do
    @client.stubs(:review).returns([@member1.email])
    @client.expects(:del).once
    get :unsubscribe, profile: @profile.identifier, id: @member1.id
  end

  should 'do nothing if the user is not subscribed' do
    @client.stubs(:review).returns([@member2.email])
    @client.expects(:del).never
    get :unsubscribe, profile: @profile.identifier, id: @member1.id
  end

  should 'create list and add admin and profile members to the group' do
    @client.stubs(:complex_lists).returns([])
    @client.stubs(:review).returns(['no_subscribers'])
    @client.expects(:create_list).once
    @client.expects(:add).times(@profile.members.count + 1)
    get :deploy, profile: @profile.identifier
  end

  should 'not create the list if it exists, but add the admin if he is not a member' do
    Noosfero::Plugin::Settings.new(Environment.default, MailingListPlugin,
                                   administrator_email: 'adm@mail.com').save!
    list = mock
    list.stubs(:listAddress).returns("#{@profile.identifier}@example.org")
    @client.stubs(:complex_lists).returns([list])
    @client.stubs(:review).returns([@member1.email, @member2.email])
    @client.expects(:create_list).never
    @client.expects(:add).once
    get :deploy, profile: @profile.identifier
  end

  should 'not create the list if it exists or add the admin if he is a member' do
    Noosfero::Plugin::Settings.new(Environment.default, MailingListPlugin,
                                   administrator_email: 'adm@mail.com').save!
    list = mock
    list.stubs(:listAddress).returns("#{@profile.identifier}@example.org")
    @client.stubs(:complex_lists).returns([list])
    @client.stubs(:review).returns([@member1.email, @member2.email,
                                    'adm@mail.com'])
    @client.expects(:create_list).never
    @client.expects(:add).never
    get :deploy, profile: @profile.identifier
  end

end
