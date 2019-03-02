require_relative "../test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @profile = create_user('testuser').person
  end
  attr_reader :profile

  should 'list events for the month by default' do
    date = DateTime.now.beginning_of_month
    profile.events << Event.new(:name => 'Joao Birthday', :start_date => date)
    profile.events << Event.new(:name => 'Maria Birthday', :start_date => date + 5.days)
    profile.events << Event.new(:name => 'Jose Birthday', :start_date => date + 1.month)

    get events_path(profile.identifier)

    today = DateTime.now.strftime("%B %d, %Y").html_safe
    assert_tag :tag => 'div', :attributes => {:id => "agenda-items"},
      :descendant => {:tag => 'tr', :content => "Maria Birthday"}
    assert_tag :tag => 'div', :attributes => {:id => "agenda-items"},
      :descendant => {:tag => 'tr', :content => "Joao Birthday"}
  end

  should 'display calendar of current month' do
    get events_path(profile.identifier)

    month = DateTime.now.strftime("%B %Y")
    assert_tag :tag => 'table', :attributes => {:class => /current-month/}, :descendant => {:tag => 'caption', :content => /#{month}/}
  end

  should 'display links to previous and next month' do
    get events_path(profile.identifier)

    prev_month = DateTime.now - 1.month
    next_month = DateTime.now + 1.month
    prev_month_name = prev_month.strftime("%B")
    next_month_name = next_month.strftime("%B")
    assert_tag :tag =>'a', :attributes => {:href => "/profile/#{profile.identifier}/events/#{prev_month.year}/#{prev_month.month}"}, :content => prev_month_name
    assert_tag :tag =>'a', :attributes => {:href => "/profile/#{profile.identifier}/events/#{next_month.year}/#{next_month.month}"}, :content => next_month_name
  end

  should 'see the events paginated' do
    30.times do |i|
      profile.events << Event.new(:name => "Lesson #{i}", :start_date => DateTime.now)
    end
    get events_path(profile.identifier)
    assert_equal 20, assigns(:events).size
  end

  should "show events for a specific month" do
    profile.events << Event.create(:name => 'Maria Birthday', :start_date => DateTime.new(2018, 03, 10))
    profile.events << Event.create(:name => 'Joao Birthday', :start_date => DateTime.new(2018, 05, 01))

    get events_path(profile.identifier), params: {year: 2018, month: 03}

    assert_tag :tag =>'a', :content => /Maria Birthday/
    !assert_tag :tag =>'a', :content => /Joao Birthday/
  end

  should 'show events of specific day' do
    profile.events << Event.new(:name => 'Joao Birthday', :start_date => DateTime.new(2009, 10, 28))
    profile.events << Event.new(:name => 'Jose Birthday', :start_date => DateTime.new(2018, 01, 31))

    get events_by_date_events_path(profile.identifier), params: {:year => 2009, :month => 10, :day => 28}

    assert_tag :tag => 'a', :content => /Joao Birthday/
    !assert_tag :tag => 'a', :content => /Jose Birthday/
  end

  should 'show events for month if day param is not present' do
    profile.events << Event.new(:name => 'Joao Birthday', :start_date => DateTime.new(2018, 01, 01))
    profile.events << Event.new(:name => 'Jose Birthday', :start_date => DateTime.new(2018, 01, 31))

    get events_by_date_events_path(profile.identifier), params: {:year => 2018, :month => 01}

    assert_tag :tag => 'a', :content => /Joao Birthday/
    assert_tag :tag => 'a', :content => /Jose Birthday/
  end

  should 'render div with xhr-links class if paginating the collection' do
    profile.events << Event.new(:name => 'Joao Birthday', :start_date => DateTime.new(2018, 01, 01))
    profile.events << Event.new(:name => 'Jose Birthday', :start_date => DateTime.new(2018, 01, 31))

    get events_by_date_events_path(profile.identifier), params: {:year => 2018, :month => 01}

    assert_tag :tag => 'div', :attributes => { class: 'xhr-links' }
  end

  should 'not show events page to non members of private community' do
    community = fast_create(Community, :identifier => 'private-community', :name => 'Private Community', :access => Entitlement::Levels.levels[:self])

    post events_path(community.identifier)

    assert_response :forbidden
    assert_template "profile/_private_profile"
  end

  should 'not show events page to non members of invisible community' do
    community = fast_create(Community, :identifier => 'invisible-community', :name => 'Private Community', :secret => true)

    get events_path(community.identifier)

    assert_response :forbidden
    assert_template 'shared/access_denied'
  end

  should 'show events page to members of private community' do
    community = fast_create(Community, :identifier => 'private-community', :name => 'Private Community', :access => Entitlement::Levels.levels[:self])
    community.add_member(@profile)

    login_as_rails5('testuser')

    get events_path(community.identifier)

    assert_response :success
  end

end
