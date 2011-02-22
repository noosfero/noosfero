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

  should 'have a body' do
    e = Event.new(:body => 'some useful description')
    assert_equal 'some useful description', e.body
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

  should 'set start date default value as today' do
    e = Event.new
    assert_equal Date.today, e.start_date
  end

  should 'require start date' do
    e = Event.new
    e.start_date = nil
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

  should 'be indexed by body' do
    profile = create_user('testuser').person
    e = Event.create!(:name => 'bli', :start_date => Date.new(2008, 06, 06), :profile => profile, :body => 'my surprisingly long description about my freaking nice event')
    assert_includes Event.find_by_contents('surprisingly'), e
  end

  should 'use its own icon' do
    assert_equal 'event', Event.icon_name
  end

  should 'not allow end date before start date' do
    e = Event.new(:start_date => Date.new(2008, 01, 01), :end_date => Date.new(2007,01,01))
    e.valid?
    assert e.errors.invalid?(:start_date)

    e.end_date = Date.new(2008,01,05)
    e.valid?
    assert !e.errors.invalid?(:start_date)
  end

  should 'find by range of dates' do
    profile = create_user('testuser').person
    e1 = Event.create!(:name => 'e1', :start_date =>  Date.new(2008,1,1), :profile => profile)
    e2 = Event.create!(:name => 'e2', :start_date =>  Date.new(2008,2,1), :profile => profile)
    e3 = Event.create!(:name => 'e3', :start_date =>  Date.new(2008,3,1), :profile => profile)

    found = Event.by_range(Date.new(2008, 1, 1)..Date.new(2008, 2, 28))
    assert_includes found, e1
    assert_includes found, e2
    assert_not_includes found, e3
  end

  should 'filter events by range' do
    profile = create_user('testuser').person
    e1 = Event.create!(:name => 'e1', :start_date => Date.new(2008,1,15), :profile => profile)
    assert_includes profile.events.by_range(Date.new(2008, 1, 10)..Date.new(2008, 1, 20)), e1
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
    e = Event.new(:start_date => Date.new(2008,1,1), :end_date => Date.new(2008,1,1), :link => 'http://www.myevent.org', :body => 'my somewhat short description')

    assert_tag_in_string e.to_html, :content => Regexp.new("January 1, 2008")
    assert_tag_in_string e.to_html, :content => 'my somewhat short description'
    assert_tag_in_string e.to_html, :tag => 'a', :attributes => { :href  => 'http://www.myevent.org' }, :content => 'http://www.myevent.org'
    
  end

  should 'not crash when body is blank' do
    e = Event.new
    assert_nil e.body
    assert_no_match(/_____XXXX_DESCRIPTION_GOES_HERE_XXXX_____/, e.to_html)
  end

  should 'add http:// to the link if not already present' do
    a = Event.new(:link => 'www.nohttp.net')
    assert_equal 'http://www.nohttp.net', a.link
  end

  should 'add http:// when reading link' do
    a = Event.new
    a.setting[:link] = 'www.gnu.org'
    assert_equal 'http://www.gnu.org', a.link
  end

  should 'not add http:// to empty link' do
    a = Event.new
    a.setting[:link] = ''
    assert_equal '', a.link
    a.setting[:link] = nil
    assert_equal '', a.link
  end

  should 'not escape HTML in body' do
    a = Event.new(:body => '<p>a paragraph of text</p>', :link => 'www.gnu.org')

    assert_match '<p>a paragraph of text</p>', a.to_html
  end

  should 'filter HTML in body' do
    profile = create_user('testuser').person
    e = Event.create!(:profile => profile, :name => 'test', :body => '<p>a paragraph (valid)</p><script type="text/javascript">/* this is invalid */</script>"', :link => 'www.colivre.coop.br', :start_date => Date.today)

    assert_tag_in_string e.body, :tag => 'p', :content => 'a paragraph (valid)'
    assert_no_tag_in_string e.body, :tag => 'script'
  end

  should 'nil to link' do
    e = Event.new
    assert_nothing_raised TypeError do
      e.link = nil
    end
  end

  should 'list all events' do
    profile = fast_create(Profile)
    event1 = Event.new(:name => 'Ze Birthday', :start_date => Date.today)
    event2 = Event.new(:name => 'Mane Birthday', :start_date => Date.today >> 1)
    profile.events << [event1, event2]
    assert_includes profile.events, event1
    assert_includes profile.events, event2
  end

  should 'list events by day' do
    profile = fast_create(Profile)

    today = Date.today
    yesterday_event = Event.new(:name => 'Joao Birthday', :start_date => today - 1.day)
    today_event = Event.new(:name => 'Ze Birthday', :start_date => today)
    tomorrow_event = Event.new(:name => 'Mane Birthday', :start_date => today + 1.day)

    profile.events << [yesterday_event, today_event, tomorrow_event]

    assert_equal [today_event], profile.events.by_day(today)
  end

  should 'list events in a range' do
    profile = fast_create(Profile)

    today = Date.today
    event_in_range = Event.new(:name => 'Noosfero Conference', :start_date => today - 2.day, :end_date => today + 2.day)
    event_in_day = Event.new(:name => 'Ze Birthday', :start_date => today)

    profile.events << [event_in_range, event_in_day]

    assert_equal [event_in_range], profile.events.by_day(today - 1.day)
    assert_equal [event_in_range], profile.events.by_day(today + 1.day)
    assert_equal [event_in_range, event_in_day], profile.events.by_day(today)
  end

  should 'not list events out of range' do
    profile = fast_create(Profile)

    today = Date.today
    event_in_range1 = Event.new(:name => 'Foswiki Conference', :start_date => today - 2.day, :end_date => today + 2.day)
    event_in_range2 = Event.new(:name => 'Debian Conference', :start_date => today - 2.day, :end_date => today + 3.day)
    event_out_of_range = Event.new(:name => 'Ze Birthday', :start_date => today - 5.day, :end_date => today - 3.day)

    profile.events << [event_in_range1, event_in_range2, event_out_of_range]

    assert_includes profile.events.by_day(today), event_in_range1
    assert_includes profile.events.by_day(today), event_in_range2
    assert_not_includes profile.events.by_day(today), event_out_of_range
  end

  should 'filter fields with full filter' do
    event = Event.new
    event.link = "<h1 Malformed >> html >< tag"
    event.valid?

    assert_no_match /[<>]/, event.link
  end

  should 'filter fields with white_list filter' do
    event = Event.new
    event.body = "<h1> Description </h1>"
    event.address = "<strong> Address <strong>"
    event.valid?

    assert_equal "<h1> Description </h1>", event.body
    assert_equal "<strong> Address <strong>", event.address
  end

  should 'escape malformed html tags' do
    event = Event.new
    event.body = "<h1<< Description >>/h1>"
    event.address = "<strong>><< Address <strong>"
    event.valid?

    assert_no_match /[<>]/, event.body
    assert_no_match /[<>]/, event.address
  end

  should 'not sanitize html comments' do
    event = Event.new
    event.body = '<p><!-- <asdf> << aasdfa >>> --> <h1> Wellformed html code </h1>'
    event.address = '<p><!-- <asdf> << aasdfa >>> --> <h1> Wellformed html code </h1>'
    event.valid?

    assert_match  /<!-- .* --> <h1> Wellformed html code <\/h1>/, event.body
    assert_match  /<!-- .* --> <h1> Wellformed html code <\/h1>/, event.address
  end

  should 'be translatable' do
    assert_kind_of Noosfero::TranslatableContent, Event.new
  end

  should 'tiny mce editor is enabled' do
    assert Event.new.tiny_mce?
  end

end
