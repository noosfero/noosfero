require_relative "../test_helper"

class ManageFriendshipsTest < ActionDispatch::IntegrationTest

  def setup
    FriendsController.any_instance.stubs(:get_layout).returns('application')
    ProfileController.any_instance.stubs(:get_layout).returns('application')

    Friendship.delete_all
    Person.delete_all
    @person = create_user("albert", :password => 'test',
      :password_confirmation => 'test').person
    @person.user.activate

    @friend = fast_create(Person, :identifier => "isaac")

    login(@person.identifier, 'test')
  end

  should 'remove friendships' do
    @person.add_friend(@friend)
    @friend.add_friend(@person)

    get "/myprofile/#{@person.identifier}/friends/remove/#{@friend.id}"
    assert_response :success

    post "/myprofile/#{@person.identifier}/friends/remove/#{@friend.id}",
      :confirmation => '1'
    assert_response :redirect

    follow_redirect!

    assert assigns(:friends).empty?
    refute @person.is_a_friend?(@friend)
    refute @friend.is_a_friend?(@person)
  end
end
