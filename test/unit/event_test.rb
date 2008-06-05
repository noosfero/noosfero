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

end
