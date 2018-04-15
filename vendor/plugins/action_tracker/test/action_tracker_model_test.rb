require 'test_helper'

ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3",
  :database => ":memory:"
})

ActiveRecord::Schema.define do
  create_table :some_table, :force => true do |t|
    t.column :some_column, :integer
  end
  create_table :action_tracker do |t|
    t.belongs_to :user, :polymorphic => true
    t.belongs_to :target, :polymorphic => true
    t.text :params
    t.string :verb
    t.timestamps
  end
end

class SomeModel < ActiveRecord::Base
  self.table_name = :some_table
  acts_as_trackable
end

class ActionTrackerModelTest < ActiveSupport::TestCase

  def setup
    ActionTrackerConfig.verbs = { :some_verb => { :description => "Did something" } }
    @mymodel = SomeModel.create!
    @othermodel = SomeModel.create!
    @tracked_action = ActionTracker::Record.create! :verb => :some_verb, :params => { :user => "foo" }, :user => @mymodel, :target => @othermodel
  end

  def test_has_relationship
    assert @mymodel.respond_to?(:tracked_actions)
  end

  def test_params_is_a_hash
    assert_kind_of Hash, @tracked_action.params
  end

  def test_has_a_polymorphic_relation_with_user
    assert_equal @mymodel.id, @tracked_action.user_id
    assert_equal "SomeModel", @tracked_action.user_type
    assert_equal @mymodel, @tracked_action.user
    assert_equal [@tracked_action], @mymodel.tracked_actions
  end

  def test_has_a_polymorphic_relation_with_target
    assert_equal @othermodel.id, @tracked_action.target_id
    assert_equal "SomeModel", @tracked_action.target_type
    assert_equal @othermodel, @tracked_action.target
  end

  def test_should_stringify_verb_before_validation
    ta = ActionTracker::Record.create! :user => SomeModel.create!, :verb => :some_verb
    assert_equal "some_verb", ta.verb
  end

  def test_verb_is_mandatory
    ta = ActionTracker::Record.new
    ta.valid?
    assert ta.errors.on(:verb)
    assert_raise ActiveRecord::RecordInvalid do
      ta.save!
    end
  end

  def test_user_is_mandatory
    ta = ActionTracker::Record.new :user_type => 'SomeModel', :verb => :some_verb
    ta.valid?
    assert ta.errors.on(:user)
    assert_raise ActiveRecord::RecordInvalid do
      ta.save!
    end

    ta = ActionTracker::Record.new :user_id => 2, :verb => :some_verb
    ta.valid?
    assert ta.errors.on(:user)
    assert_raise ActiveRecord::RecordInvalid do
      ta.save!
    end
  end

  def test_user_exists_indeed
    ta = ActionTracker::Record.new(:verb => :some_verb)
    ta.valid?
    assert ta.errors.on(:user)
    user = SomeModel.create!
    ta.user = user
    assert ta.valid?
    user.destroy
    ta.valid?
    assert ta.errors.on(:user)
  end

  def test_verb_must_be_declared_previously
    ActionTrackerConfig.verbs = { :some_verb => { :description => "Did something" } }
    assert_raise ActiveRecord::RecordInvalid do
      ta = ActionTracker::Record.create! :verb => :undeclared_verb
    end
    ActionTrackerConfig.verbs = { :declared_verb => { :description => "Did something" } }
    assert_nothing_raised do
      ta = ActionTracker::Record.create! :user => SomeModel.create!, :verb => :declared_verb
    end
  end

  def test_update_or_create_create_if_there_is_no_last
    ActionTrackerConfig.verbs = { :some => { :description => "Something", :type => :updatable } }
    ActionTracker::Record.delete_all
    assert_difference "ActionTracker::Record.count" do
      ta = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel
      ta.save; ta.reload
      assert_kind_of ActionTracker::Record, ta
    end
    assert_equal "some", ActionTracker::Record.last.verb
    assert_equal @mymodel, ActionTracker::Record.last.user
  end

  def test_update_or_create_create_if_timeout
    ActionTrackerConfig.verbs = { :some => { :description => "Something", :type => :updatable } }
    ActionTrackerConfig.timeout = 5.minutes
    ActionTracker::Record.delete_all
    ta = nil
    assert_difference "ActionTracker::Record.count" do
      ta = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel
      ta.save; ta.reload
    end
    assert_kind_of ActionTracker::Record, ta
    ta.updated_at = Time.now.ago(6.minutes)
    ta.send :update_without_callbacks
    t = ta.reload.updated_at
    assert_difference "ActionTracker::Record.count" do
      ta2 = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel
      ta2.save; ta2.reload
      assert_kind_of ActionTracker::Record, ta2
    end
    assert_equal t, ta.reload.updated_at
  end

  def test_update_or_create_update_if_no_timeout
    ActionTrackerConfig.verbs = { :some => { :description => "Something", :type => :updatable } }
    ActionTrackerConfig.timeout = 7.minutes
    ActionTracker::Record.delete_all
    ta = nil
    assert_difference "ActionTracker::Record.count" do
      ta = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel, :params => { :foo => 2 }
      ta.save; ta.reload
    end
    assert_kind_of ActionTracker::Record, ta
    assert_equal 2, ta.get_foo
    ta.updated_at = Time.now.ago(6.minutes)
    ta.send :update_without_callbacks
    t = ta.reload.updated_at
    assert_no_difference "ActionTracker::Record.count" do
      ta2 = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel, :params => { :foo => 3 }
      ta2.save; ta2.reload
      assert_kind_of ActionTracker::Record, ta2
    end
    assert_not_equal t, ta.reload.updated_at
    assert_equal 3, ta.reload.get_foo
  end

  def test_should_update_or_create_method_create_a_new_tracker_with_different_dispacthers
    ActionTrackerConfig.verbs = { :some => { :description => "Something", :type => :updatable } }
    ActionTracker::Record.delete_all
    ta = nil
    assert_difference "ActionTracker::Record.count" do
      ta = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel, :target => @mymodel, :params => { :foo => 2 }
      ta.save; ta.reload
    end
    assert_kind_of ActionTracker::Record, ta
    t = ta.reload.updated_at
    sleep(1)
    assert_no_difference "ActionTracker::Record.count" do
      ta2 = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel, :target => @mymodel, :params => { :foo => 3 }
      ta2.save; ta2.reload
      assert_kind_of ActionTracker::Record, ta2
    end
    assert_equal 3, ta.reload.get_foo
    assert_not_equal t, ta.reload.updated_at

    assert_kind_of ActionTracker::Record, ta
    t = ta.reload.updated_at
    assert_difference "ActionTracker::Record.count" do
      ta2 = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel, :target => @othermodel, :params => { :foo => 4 }
      ta2.save; ta2.reload
      assert_kind_of ActionTracker::Record, ta2
    end
    assert_equal t, ta.reload.updated_at
    assert_equal 3, ta.reload.get_foo
  end

  def test_add_or_create_create_if_timeout
    ActionTrackerConfig.verbs = { :some => { :description => "Something", :type => :groupable } }
    ActionTrackerConfig.timeout = 5.minutes
    ActionTracker::Record.delete_all
    ta = nil
    assert_difference "ActionTracker::Record.count" do
      ta = ActionTracker::Record.add_or_create :verb => :some, :user => @mymodel, :params => { :foo => "bar" }
      ta.save; ta.reload
    end
    assert_kind_of ActionTracker::Record, ta
    assert_equal ["bar"], ta.reload.params[:foo]
    ta.created_at = Time.now.ago(6.minutes)
    ta.send :update_without_callbacks
    t = ta.reload.updated_at
    assert_difference "ActionTracker::Record.count" do
      ta2 = ActionTracker::Record.add_or_create :verb => :some, :user => @mymodel, :params => { :foo => "test" }
      ta2.save; ta2.reload
      assert_kind_of ActionTracker::Record, ta2
    end
    assert_equal t, ta.reload.updated_at
    assert_equal ["test"], ActionTracker::Record.last.params[:foo]
  end

  def test_add_or_create_update_if_no_timeout
    ActionTrackerConfig.verbs = { :some => { :description => "Something", :type => :updatable } }
    ActionTrackerConfig.timeout = 7.minutes
    ActionTracker::Record.delete_all
    ta = nil
    assert_difference "ActionTracker::Record.count" do
      ta = ActionTracker::Record.add_or_create :verb => :some, :user => @mymodel, :params => { :foo => "test 1", :bar => 2 }
      ta.save; ta.reload
    end
    assert_kind_of ActionTracker::Record, ta
    assert_equal ["test 1"], ta.params[:foo]
    assert_equal [2], ta.params[:bar]
    ta.updated_at = Time.now.ago(6.minutes)
    ta.send :update_without_callbacks
    t = ta.reload.updated_at
    assert_no_difference "ActionTracker::Record.count" do
      ta2 = ActionTracker::Record.add_or_create :verb => :some, :user => @mymodel, :params => { :foo => "test 2", :bar => 1 }
      ta2.save; ta2.reload
      assert_kind_of ActionTracker::Record, ta2
    end
    assert_equal ["test 1", "test 2"], ActionTracker::Record.last.params[:foo]
    assert_equal [2, 1], ActionTracker::Record.last.params[:bar]
    assert_not_equal t, ta.reload.updated_at
    assert_no_difference "ActionTracker::Record.count" do
      ta = ActionTracker::Record.add_or_create :verb => :some, :user => @mymodel, :params => { :foo => "test 1", :bar => 1 }
      ta.save; ta.reload
    end
    assert_equal ["test 1", "test 2", "test 1"], ActionTracker::Record.last.params[:foo]
    assert_equal [2, 1, 1], ActionTracker::Record.last.params[:bar]
  end

  def test_add_or_create_create_if_no_timeout_and_different_target
    ActionTrackerConfig.verbs = { :some => { :description => "Something", :type => :updatable } }
    ActionTrackerConfig.timeout = 7.minutes
    ActionTracker::Record.delete_all
    ta = nil
    assert_difference "ActionTracker::Record.count" do
      ta = ActionTracker::Record.add_or_create :verb => :some, :user => @mymodel, :target => @mymodel, :params => { :foo => "test 1", :bar => 2 }
      ta.save; ta.reload
    end
    assert_kind_of ActionTracker::Record, ta
    assert_equal ["test 1"], ta.params[:foo]
    assert_equal [2], ta.params[:bar]
    ta.updated_at = Time.now.ago(6.minutes)
    ta.send :update_without_callbacks
    t = ta.reload.updated_at
    assert_difference "ActionTracker::Record.count" do
      ta2 = ActionTracker::Record.add_or_create :verb => :some, :user => @mymodel, :target => @othermodel, :params => { :foo => "test 2", :bar => 1 }
      ta2.save; ta2.reload
      assert_kind_of ActionTracker::Record, ta2
    end
    assert_equal ["test 1"], ta.params[:foo]
    assert_equal [2], ta.params[:bar]
  end

  def test_time_spent
    ActionTracker::Record.delete_all
    ActionTrackerConfig.verbs = { :some => { :description => "Something", :type => :updatable } }
    t = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel
    t.save; t.reload
    t.created_at = t.created_at.ago(2.days)
    t.updated_at = t.created_at.tomorrow
    t.send :update_without_callbacks
    ActionTrackerConfig.timeout = 5.minutes
    t = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel
    t.save; t.reload
    t.created_at = t.updated_at.ago(2.hours)
    t.send :update_without_callbacks
    assert_equal 2, ActionTracker::Record.count
    assert_equal 26.hours, ActionTracker::Record.time_spent
  end

  def test_duration
    ActionTracker::Record.delete_all
    ActionTrackerConfig.verbs = { :some => { :description => "Something", :type => :updatable } }
    ActionTrackerConfig.timeout = 5.minutes
    t = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel; t.save
    t = ActionTracker::Record.update_or_create :verb => :some, :user => @mymodel; t.save
    t.reload
    t.created_at = t.updated_at.ago(2.minutes)
    t.send :update_without_callbacks
    assert_equal 1, ActionTracker::Record.count
    assert_equal 2.minutes, t.reload.duration
  end

  def test_describe
    ActionTracker::Record.delete_all
    ActionTrackerConfig.verbs = { :some => { :description => "Who done this is from class {{user.class.to_s}} and half of its value is {{params[:value].to_i/2}}" } }
    ActionTrackerConfig.timeout = 5.minutes
    t = ActionTracker::Record.create! :verb => :some, :user => @mymodel, :params => { :value => "10" }
    assert_equal "Who done this is from class SomeModel and half of its value is 5", t.describe
  end

  def test_description
    ActionTrackerConfig.verbs = { :some => { :description => "Got {{it}}" } }
    t = ActionTracker::Record.create! :user => SomeModel.create!, :verb => :some
    assert_equal "Got {{it}}", t.description
    ActionTrackerConfig.verbs = { :some => nil }
    t = ActionTracker::Record.create! :user => SomeModel.create!, :verb => :some
    assert_equal "", t.description
  end

  def test_subject
    ActionTrackerConfig.verbs = { :some => { :description => "Some" } }
    u = SomeModel.create!
    t = ActionTracker::Record.create! :verb => :some, :user => u
    assert_equal u, t.subject
  end

  def test_predicate
    ActionTrackerConfig.verbs = { :some => { :description => "Some" } }
    t = ActionTracker::Record.create! :user => SomeModel.create!, :verb => :some, :params => nil
    assert_equal({}, t.predicate)
    t = ActionTracker::Record.create! :user => SomeModel.create!, :verb => :some, :params => { :foo => "bar" }
    assert_equal({ :foo => "bar" }, t.predicate)
  end

  def test_phrase
    ActionTrackerConfig.verbs = { :some => { :description => "Some" } }
    u = SomeModel.create!
    t = ActionTracker::Record.create! :verb => :some, :params => { :foo => "bar" }, :user => u
    assert_equal({ :subject => u, :verb => "some", :predicate => { :foo => "bar" }}, t.phrase)
  end

  def test_method_missing
    ActionTrackerConfig.verbs = { :some => { :description => "Some" } }
    t = ActionTracker::Record.create! :user => SomeModel.create!, :verb => :some, :params => { :foo => "test 1", "bar" => "test 2" }
    assert_nil t.get_test
    assert_equal "test 1", t.get_foo
    assert_equal "test 2", t.get_bar
    assert_raise NoMethodError do
      t.another_unknown_method
    end
  end

  def test_collect_group_with_index
    ActionTrackerConfig.verbs = { :some => { :description => "Some" }, :type => :groupable }
    t = ActionTracker::Record.create! :user => SomeModel.create!, :verb => :some, :params => { "test" => ["foo", "bar"] }
    assert_equal(["foo 1", "bar 2"], t.collect_group_with_index(:test){|x, i| "#{x} #{i+1}" })
  end

  def test_recent_filter_actions
    ActionTracker::Record.destroy_all
    t1 = ActionTracker::Record.create!(:user => SomeModel.create!, :verb => :some_verb, :created_at => Time.now)
    t2 = ActionTracker::Record.create!(:user => SomeModel.create!, :verb => :some_verb, :created_at => ActionTracker::Record::RECENT_DELAY.days.ago - 1.day)
    assert_equal [t1], ActionTracker::Record.recent.all
  end
end
