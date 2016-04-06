module ObserversTestHelper

  def create_add_friend_task
    user1 = fast_create(User)
    person = fast_create(Person, :user_id => user1.id)
    user2 = fast_create(User)
    friend = fast_create(Person, :user_id => user2.id)
    return AddFriend.create!(:requestor => person, :target => friend)
  end

  def create_add_member_task
    person = fast_create(Person)
    community = fast_create(Community)
    return AddMember.create!(:requestor => person, :target => community)
  end

  def create_suggest_article_task
    person = fast_create(Person)
    community = fast_create(Community)
    return SuggestArticle.create!(:target => community, :article => {:name => 'Munchkin', :body => 'Kill monsters!! Get treasures!! Stab your friends!!'}, :requestor => person)
  end

  def create_approve_article_task
    user1 = fast_create(User)
    person = fast_create(Person, :user_id => user1.id)
    article = fast_create(Article, :profile_id => person.id)
    community = fast_create(Community)
    community.add_member(person)
    community.save!

    return ApproveArticle.create!(:article => article, :target => community, :requestor => person)
  end
end
