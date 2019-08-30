require_relative "../test_helper"

class MapBalloonControllerTest < ActionController::TestCase
  def setup
    @controller = MapBalloonController.new

    @profile = create_user("test_profile").person
    login_as(@profile.identifier)
  end

  should "find person to show" do
    pers = create(Person, name: "Person1", user_id: fast_create(User).id, identifier: "pers1")
    get :person, id: pers.id
    assert_equal pers, assigns(:profile)
  end

  should "find enterprise to show" do
    ent = Enterprise.create!(name: "Enterprise1", identifier: "ent1")
    get :enterprise, id: ent.id
    assert_equal ent, assigns(:profile)
  end

  should "find community to show" do
    comm = Community.create!(name: "Community1", identifier: "comm1")
    get :community, id: comm.id
    assert_equal comm, assigns(:profile)
  end
end
