require "test_helper"
class EntityTest < ActiveSupport::TestCase
  
	def setup
    @hash = {:name => 'Carlos', :age => 25,
      :brothers => [{:name => 'Saulo', :age => 22}, {:name => 'Isis', :age => 26}]}
		@person = Person.create('Carlos', 25)
    @person.brothers = [Person.create('Saulo', 22), Person.create('Isis', 26)]
    @clone = @person.clone
	end

	should 'be equal to clone' do
	  assert_equal @person, @clone
	end

	should 'be different when field is different' do
    @clone.name = 'Other'
	  assert @person != @clone
	end

  should 'not throw exception when comparing with incompatible object' do
    assert @person != @hash
  end

  should 'create from hash' do
    assert_equal @person, Person.from_hash(@hash)
  end

  should 'convert to hash' do
    assert_equal @hash, @person.to_hash
  end

  class Person < Kalibro::Entities::Entity

    attr_accessor :name, :age, :brothers

    def self.create(name, age)
      person = Person.new
      person.name = name
      person.age = age
      person
    end

    def brothers=(value)
      @brothers = to_entity_array(value, Person)
    end

  end

end