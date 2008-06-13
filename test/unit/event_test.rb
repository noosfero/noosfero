require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase

  should 'be an article' do
    assert_kind_of Article, Event.new
  end

  should 'provide description' do
    assert_kind_of String, Event.description
  end

  should 'provide short description' do
    assert_kind_of String, Event.short_description
  end

  should 'have a description' do
    e = Event.new(:description => 'some useful description')
    assert_equal 'some useful description', e.description
  end

  should 'have a link' do
    e = Event.new(:link => 'http://some.nice.site/')
    assert_equal 'http://some.nice.site/', e.link
  end

  should 'have an address' do
    e = Event.new(:address => 'South Noosfero street, 88')
    assert_equal 'South Noosfero street, 88', e.address
  end

  should 'have a start date' do
    e = Event.new
    e.start_date = Date.today
    assert_kind_of Date, e.start_date
  end

  should 'require start date' do
    e = Event.new
    e.valid?
    assert e.errors.invalid?(:start_date)
    e.start_date = Date.today
    e.valid?
    assert !e.errors.invalid?(:start_date)
  end

  should 'have a end date' do
    e = Event.new
    e.end_date = Date.today
    assert_kind_of Date, e.end_date
  end

  should 'be indexed by title' do
    profile = create_user('testuser').person
    e = Event.create!(:name => 'my surprisingly nice event', :start_date => Date.new(2008, 06, 06), :profile => profile)
    assert_includes Event.find_by_contents('surprisingly'), e
  end

  should 'be indexed by description' do
    profile = create_user('testuser').person
    e = Event.create!(:name => 'bli', :start_date => Date.new(2008, 06, 06), :profile => profile, :description => 'my surprisingly long description about my freaking nice event')
    assert_includes Event.find_by_contents('surprisingly'), e
  end

  should 'use its own icon' do
    assert_equal 'event', Event.new.icon_name
  end

  should 'not allow end date before start date' do
    e = Event.new(:start_date => Date.new(2008, 01, 01), :end_date => Date.new(2007,01,01))
    e.valid?
    assert e.errors.invalid?(:start_date)

    e.end_date = Date.new(2008,01,05)
    e.valid?
    assert !e.errors.invalid?(:start_date)
  end

  should 'find by year and month' do
    profile = create_user('testuser').person
    e1 = Event.create!(:name => 'e1', :start_date =>  Date.new(2008,1,1), :profile => profile)
    e2 = Event.create!(:name => 'e2', :start_date =>  Date.new(2008,2,1), :profile => profile)
    e3 = Event.create!(:name => 'e3', :start_date =>  Date.new(2008,3,1), :profile => profile)

    found = Event.by_month(2008, 2)
    assert_includes found, e2
    assert_not_includes found, e1
    assert_not_includes found, e3
  end

  should 'find when in first day of month' do
    profile = create_user('testuser').person
    e1 = Event.create!(:name => 'e1', :start_date =>  Date.new(2008,1,1), :profile => profile)
    assert_includes Event.by_month(2008, 1), e1
  end

  should 'find when in last day of month' do
    profile = create_user('testuser').person
    e1 = Event.create!(:name => 'e1', :start_date =>  Date.new(2008,1,31), :profile => profile)
    assert_includes Event.by_month(2008, 1), e1
  end

  should 'use current month by default' do
    profile = create_user('testuser').person
    e1 = Event.create!(:name => 'e1', :start_date =>  Date.new(2008,1,31), :profile => profile)
    Date.expects(:today).returns(Date.new(2008, 1, 15))
    assert_includes Event.by_month, e1
  end

  should 'provide period for searching in month' do
    assert_equal Date.new(2008, 1, 1)..Date.new(2008,1,31), Event.date_range(2008, 1)
    assert_equal Date.new(2008, 2, 1)..Date.new(2008,2,29), Event.date_range(2008, 2)
    assert_equal Date.new(2007, 2, 1)..Date.new(2007,2,28), Event.date_range(2007, 2)
  end

  should 'support string arguments to Event#date_range' do
    assert_equal Date.new(2008,1,1)..Date.new(2008,1,31), Event.date_range('2008', '1')
  end

  should 'provide range of dates for event with both dates filled' do
    e = Event.new(:start_date => Date.new(2008, 1, 1), :end_date => Date.new(2008, 1, 5))
    
    assert_equal (Date.new(2008,1,1)..Date.new(2008,1,5)), e.date_range
  end

  should 'provide range of dates for event with only start date' do
    e = Event.new(:start_date => Date.new(2008, 1, 1))
    
    assert_equal (Date.new(2008,1,1)..Date.new(2008,1,1)), e.date_range
  end

  should 'provide nice display format' do
    e = Event.new(:start_date => Date.new(2008,1,1), :end_date => Date.new(2008,1,1), :link => 'http://www.myevent.org', :description => 'my somewhat short description')

    assert_tag_in_string e.to_html, :content => Regexp.new("1 January 2008")
    assert_tag_in_string e.to_html, :content => 'my somewhat short description'
    assert_tag_in_string e.to_html, :tag => 'a', :attributes => { :href  => 'http://www.myevent.org' }, :content => 'http://www.myevent.org'
    
  end

  should 'add http:// to the link if not already present' do
    a = Event.new(:link => 'www.nohttp.net')
    assert_equal 'http://www.nohttp.net', a.link
  end

  protected

  def assert_tag_in_string(text, options)
    doc = HTML::Document.new(text, false, false)
    tag = doc.find(options)
    assert tag, "expected tag #{options.inspect}, but not found in #{text.inspect}"
  end

end
