require_relative '../test_helper'

class CirclesControllerTest < ActionController::TestCase

  def setup
    @controller = CirclesController.new
    @person = create_user('person').person
    login_as(@person.identifier)
  end

  should 'return all circles of a profile' do
    circle1 = Circle.create!(:name => "circle1", :person => @person, :profile_type => 'Person')
    circle2 = Circle.create!(:name => "circle2", :person => @person, :profile_type => 'Person')
    get :index, :profile => @person.identifier

    assert_equivalent [circle1, circle2], assigns[:circles]
  end

  should 'initialize an empty circle for creation' do
    get :new, :profile => @person.identifier
    assert_nil assigns[:circle].id
    assert_nil assigns[:circle].name
  end

  should 'create a new circle' do
    assert_difference '@person.circles.count' do
      post :create, :profile => @person.identifier,
                    :circle => { :name => 'circle' , :profile_type => Person.name}
    end
    assert_redirected_to :action => :index
  end

  should 'not create a circle without a name' do
    assert_no_difference '@person.circles.count' do
      post :create, :profile => @person.identifier, :circle => { :name => nil }
    end
    assert_template :new
  end

  should 'retrieve an existing circle when editing' do
    circle = Circle.create!(:name => "circle", :person => @person, :profile_type => 'Person')
    get :edit, :profile => @person.identifier, :id => circle.id
    assert_equal circle.name, assigns[:circle].name
  end

  should 'return 404 when editing a circle that does not exist' do
    get :edit, :profile => @person.identifier, :id => "nope"
    assert_response 404
  end

  should 'update an existing circle' do
    circle = Circle.create!(:name => "circle", :person => @person, :profile_type => 'Person')
    post :update, :profile => @person.identifier, :id => circle.id,
                  :circle => { :name => "new name" }

    circle.reload
    assert_equal "new name", circle.name
    assert_redirected_to :action => :index
  end

  should 'not update an existing circle without a name' do
    circle = Circle.create!(:name => "circle", :person => @person, :profile_type => 'Person')
    post :update, :profile => @person.identifier, :id => circle.id,
                  :circle => { :name => nil }

    circle.reload
    assert_equal "circle", circle.name
    assert_template :edit
  end

  should 'return 404 when updating a circle that does not exist' do
    post :update, :profile => @person.identifier, :id => "nope", :name => "new name"
    assert_response 404
  end

  should 'destroy an existing circle and remove related profiles' do
    circle = Circle.create!(:name => "circle", :person => @person, :profile_type => 'Person')
    fast_create(ProfileFollower, :profile_id => fast_create(Person).id, :circle_id => circle.id)

    assert_difference ["@person.circles.count", 'ProfileFollower.count'], -1 do
      post :destroy, :profile => @person.identifier, :id => circle.id
    end
  end

  should 'not destroy an existing circle if action is not post' do
    circle = Circle.create!(:name => "circle", :person => @person, :profile_type => 'Person')

    assert_no_difference "@person.circles.count" do
      get :destroy, :profile => @person.identifier, :id => circle.id
    end
    assert_response 404
  end

  should 'return 404 when deleting and circle that does not exist' do
    get :destroy, :profile => @person.identifier, :id => "nope"
    assert_response 404
  end

  should 'return 404 for xhr_create if request is not xhr' do
    post :xhr_create, :profile => @person.identifier
    assert_response 404
  end

  should 'return 400 if not possible to create circle via xhr' do
    xhr :post, :xhr_create, :profile => @person.identifier,
                            :circle => { :name => 'Invalid Circle' }
    assert_response 400
  end

  should 'create a new circle via xhr' do
    xhr :post, :xhr_create, :profile => @person.identifier,
                            :circle => { :name => 'A Brand New Circle',
                                         :profile_type => Person.name }
    assert_response 201
    assert_match /A Brand New Circle/, response.body
  end

  should 'not create a new circle via xhr with an invalid profile_type' do
    xhr :post, :xhr_create, :profile => @person.identifier,
                            :circle => { :name => 'A Brand New Circle',
                                         :profile_type => '__invalid__' }
    assert_response 400
  end
end
