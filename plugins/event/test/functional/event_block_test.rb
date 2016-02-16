require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    @env = Environment.default
    @env.enable_plugin('EventPlugin')

    @p1  = fast_create(Person, :environment_id => @env.id)
    @e1a = Event.create!(:name=>'Event p1 A', :profile =>@p1)

    box = Box.create!(:owner => @env)
    @block = EventPlugin::EventBlock.create!(:box => box)
  end

  # Event item CSS selector
  ev = '.event-plugin_event-block ul.events li.event[itemscope]' +
       '[itemtype="http://data-vocabulary.org/Event"] '

  should 'see events microdata sturcture' do
    get :index
#raise response.body.inspect
    assert_select '.event-plugin_event-block ul.events'
    assert_select ev
    assert_select ev + 'a[itemprop="url"]'
    assert_select ev + 'time.date[itemprop="startDate"][datetime]'
    assert_select ev + 'time.date .day'
    assert_select ev + 'time.date .month'
    assert_select ev + 'time.date .year'
    assert_select ev + '.title[itemprop="summary"]'
    assert_select ev + '.address[itemprop="location"] *[itemprop="name"]'
    assert_select ev + '.days-left'
  end

  should 'see event duration' do
    @e1a.slug = 'event1a'
    @e1a.start_date = DateTime.now
    @e1a.end_date = DateTime.now + 1.day
    @e1a.save!
    get :index
    assert_select ev + 'time.duration[itemprop="endDate"]', /2 days/

    @e1a.slug = 'event1a'
    @e1a.start_date = DateTime.now
    @e1a.end_date = DateTime.now + 2.day
    @e1a.save!
    get :index
    assert_select ev + 'time.duration[itemprop="endDate"]', /3 days/
  end

  should 'not see event duration for one day events' do
    get :index
    assert_select ev + 'time.duration[itemprop="endDate"]', false

    @e1a.slug = 'event1a'
    @e1a.start_date = DateTime.now
    @e1a.end_date = DateTime.now
    @e1a.save!
    get :index
    assert_select ev + 'time.duration[itemprop="endDate"]', false
  end

end
