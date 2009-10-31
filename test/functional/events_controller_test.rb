require File.dirname(__FILE__) + '/../test_helper'

class EventsControllerTest < ActionController::TestCase

  def setup
    @profile = create_user('testuser').person
  end
  attr_reader :profile

  should 'hide sideboxes when show calendar' do
    get :events, :profile => profile.identifier
    assert_no_tag :tag => 'div', :attributes => {:id => 'boxes'}
  end

  should 'list today events by default' do
    profile.events << Event.new(:name => 'Joao Birthday', :start_date => Date.today)
    profile.events << Event.new(:name => 'Maria Birthday', :start_date => Date.today)

    get :events, :profile => profile.identifier

    today = Date.today.strftime("%B %d, %Y")
    assert_tag :tag => 'div', :attributes => {:id => "agenda-items"},
      :descendant => {:tag => 'h3', :content => "Events for #{today}"},
      :descendant => {:tag => 'tr', :content => "Joao Birthday"},
      :descendant => {:tag => 'tr', :content => "Maria Birthday"}
  end

  should 'display calendar of current month' do
    get :events, :profile => profile.identifier

    month = Date.today.strftime("%B %Y")
    assert_tag :tag => 'table', :attributes => {:class => /current-month/}, :descendant => {:tag => 'caption', :content => /#{month}/}
  end

  should 'display calendar of previous month' do
    get :events, :profile => profile.identifier

    month = (Date.today << 1).strftime("%B %Y")
    assert_tag :tag => 'table', :attributes => {:class => /previous-month/}, :descendant => {:tag => 'caption', :content => /#{month}/}
  end

  should 'display calendar of next month' do
    get :events, :profile => profile.identifier

    month = (Date.today >> 1).strftime("%B %Y")
    assert_tag :tag => 'table', :attributes => {:class => /next-month/}, :descendant => {:tag => 'caption', :content => /#{month}/}
  end

  should 'display links to previous and next month' do
    get :events, :profile => profile.identifier

    prev_month = Date.today << 1
    next_month = Date.today >> 1
    assert_tag :tag =>'a', :attributes => {:href => "/profile/#{profile.identifier}/events/#{next_month.year}/#{next_month.month}"}, :content => /next/
    assert_tag :tag =>'a', :attributes => {:href => "/profile/#{profile.identifier}/events/#{prev_month.year}/#{prev_month.month}"}, :content => /previous/
  end

end
