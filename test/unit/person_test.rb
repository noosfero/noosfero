require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < Test::Unit::TestCase
  fixtures :profiles, :users, :comatose_pages

  def test_person_must_come_form_the_cration_of_an_user
    p = Person.new(:name => 'John', :identifier => 'john')
    assert !p.valid?
    p.user =  User.create(:login => 'john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')
    assert !p.valid?
    p = User.create(:login => 'johnz', :email => 'johnz@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe').person
    assert p.valid?
  end

  def test_can_associate_to_a_profile
    pr = Profile.new(:identifier => 'mytestprofile', :name => 'My test profile')
    assert pr.save
    pe = User.create(:login => 'person', :email => 'person@test.net', :password => 'dhoe', :password_confirmation => 'dhoe').person
    assert pe.save
    member_role = Role.create(:name => 'member')
    pr.affiliate(pe, member_role) 
    assert pe.profiles.include?(pr)
  end

  def test_can_belongs_to_an_enterprise
    e = Enterprise.new(:identifier => 'enterprise', :name => 'enterprise')
    assert e.save
    p = User.create(:login => 'person', :email => 'person@test.net', :password => 'dhoe', :password_confirmation => 'dhoe').person
    assert p.save
    member_role = Role.create(:name => 'member')
    e.affiliate(p, member_role)
    assert p.enterprises.include?(e)
  end
  
  def test_can_have_user
    u = User.new(:login => 'john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')
    p = Person.new(:name => 'John', :identifier => 'john')
    u.person = p
    assert u.save
    assert_kind_of User, p.user
    assert_equal 'John', u.person.name
  end

  def test_only_one_person_per_user
    u = User.new(:login => 'john', :email => 'john@doe.org', :password => 'dhoe', :password_confirmation => 'dhoe')
    assert u.save

    p1 = u.person
    assert_equal u, p1.user
    
    p2 = Person.new
    p2.user = u
    assert !p2.valid?
    assert p2.errors.invalid?(:user_id)
  end

  should "have person info" do
    p = Person.new
    assert_kind_of PersonInfo, p.person_info
  end

  should 'return person_info as info' do
    p = Person.new
    assert_equal p.person_info, p.info
  end

end
