require_relative "../test_helper"

class InvitationTest < ActiveSupport::TestCase

  should 'expand message' do
    invitation = Invitation.new(
      :person => create_user('sadam', {}, :name => 'Sadam').person,
      :friend_name => 'Fernandinho',
      :message => 'Hi <friend>, <user> is inviting you to <environment>!'
    )
    assert_equal 'Hi Fernandinho, Sadam is inviting you to %s!' % Environment.default.name, invitation.expanded_message
  end

  should 'require subclasses implement mail_template method' do
    assert_raise RuntimeError do
      Invitation.new.mail_template
    end
  end

  should 'join string contacts with array contacts' do
    string_contacts = "sadam@garotos\nfernandinho@garotos\roi@garotos"
    array_contacts = ['casiotone@gengivas.negras']

    assert_equal ['sadam@garotos', 'fernandinho@garotos', 'oi@garotos', 'casiotone@gengivas.negras'],
      Invitation.join_contacts(string_contacts, array_contacts)
  end

  should 'raises when try get contacts from unknown source' do
    contact_list = ContactList.create
    assert_raise NotImplementedError do
      Invitation.get_contacts('ze', 'ze12', 'bli-mail', contact_list.id)
    end
  end

  should 'not know how to invite members to non-community' do
    person = fast_create(Person)
    enterprise = fast_create(Enterprise)

    assert_raise NotImplementedError do
      Invitation.invite(person, ['sadam@garotos.podres'], 'hello friend', enterprise)
    end
  end

  should 'create right task when invite friends' do
    person = fast_create(Person)
    person.user = User.new(:email => 'current_user@email.invalid')

    assert_difference 'InviteFriend.count' do
      Invitation.invite(person, ['sadam@garotos.podres'], 'hello friend <url>', person)
    end
  end

  should 'create right task when invite members to community' do
    person = fast_create(Person)
    person.user = User.new(:email => 'current_user@email.invalid')
    community = fast_create(Community)

    assert_difference 'InviteMember.count' do
      Invitation.invite(person, ['sadam@garotos.podres'], 'hello friend <url>', community)
    end
  end

  should 'not create task if the invited member is already a member of the community' do
    person = fast_create(Person)
    person.user = User.new(:email => 'current_user@email.invalid')
    community = fast_create(Community)
    user_to_invite = fast_create(User, :email => 'person_to_invite@email.invalid')
    person_to_invite = fast_create(Person, :user_id => user_to_invite.id)
    community.add_member(person_to_invite)

    assert_no_difference 'InviteMember.count' do
      Invitation.invite(person, ['person_to_invite@email.invalid'], 'hello friend <url>', community)
    end
  end

  should 'not crash if the invited friend is already your friend in the environment' do
    person = create_user('person').person
    invited_friend = create_user('invited_friend').person
    community       = fast_create(Community)

    invited_friend.add_friend(person)

    assert_nothing_raised NoMethodError do
      Invitation.invite( person, [invited_friend.user.email], "", community )
    end
  end

  should 'do nothing if the invited friend is already your friend' do
    person = create_user('person').person
    invited_friend = create_user('invited_friend').person

    invited_friend.add_friend(person)

    assert_no_difference 'InviteFriend.count' do
      Invitation.invite( person, [invited_friend.user.email], "", person )
    end
  end

  should 'and yet be able to invite friends to community' do
    person = create_user('person').person
    invited_friend = create_user('invited_friend').person

    invited_friend.add_friend(person)
    community = fast_create(Community)

    assert_difference 'InviteMember.count' do
      Invitation.invite( person, [invited_friend.user.email], "", community )
    end
  end

  should 'add url on message if user removed it' do
    person = create_user('testuser1').person
    friend = create_user('testuser2').person
    invitation = Invitation.create!(
      :person => person,
      :friend => friend,
      :message => 'Hi <friend>, <user> is inviting you!'
    )
    assert_equal "Hi <friend>, <user> is inviting you!#{Invitation.default_message_to_accept_invitation}", invitation.message
  end

  should 'do nothing with message if user added url' do
    person = create_user('testuser1').person
    friend = create_user('testuser2').person
    invitation = Invitation.create!(
      :person => person,
      :friend => friend,
      :message => 'Hi <friend>, <user> is inviting you to be his friend on <url>!'
    )
    assert_equal "Hi <friend>, <user> is inviting you to be his friend on <url>!", invitation.message
  end

  should 'have a message with url' do
    assert_equal "\n\nTo accept invitation, please follow this link: <url>", Invitation.default_message_to_accept_invitation
  end

  should 'invite friends through profile id' do
    person = create_user('testuser1').person
    friend = create_user('testuser2').person
    community = fast_create(Community)

    assert_difference 'InviteMember.count' do
      Invitation.invite(person, [friend.id.to_s], 'hello friend <url>', community)
    end
    assert_difference 'InviteFriend.count' do
      Invitation.invite(person, [friend.id.to_s], 'hello friend <url>', person)
    end
  end

end
