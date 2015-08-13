require 'test_helper'

ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3",
  :database => ":memory:"
})

ActiveRecord::Schema.define do
  create_table :some_table, :force => true do |t|
    t.column :some_column, :string
  end
  create_table :other_table, :force => true do |t|
    t.column :other_column, :string
    t.column :another_column, :integer
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

class OtherModel < ActiveRecord::Base
  self.table_name = :other_table
  acts_as_trackable
end

class ThingsController < ActionController::Base

  def index
    params[:foo] = params[:foo].to_i + 1
    render :text => "test"
  end

  def test
    render :text => "test"
  end

  def rescue_action(e)
    raise e
  end

end

ActionController::Routing::Routes.draw { |map| map.resources :things, :collection => { :test => :get } }

class ActionTrackerTest < ActiveSupport::TestCase

  def setup
    ActionTrackerConfig.current_user = proc{ SomeModel.first || SomeModel.create! }
    ActionTracker::Record.delete_all
    ActionTrackerConfig.verbs = { :some_verb => { :description => "Did something" } }
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @controller = ThingsController.new
  end

  def test_index
    get :index
    assert_response :success
  end

  def test_track_actions_after_runs_after_action
    @controller = create_controller { track_actions_after :some_verb }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => "4"
    end
    assert_equal 5, ActionTracker::Record.first.params[:foo]
  end

  def test_track_actions_after_runs_before_action
    @controller = create_controller { track_actions_before :some_verb }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => "4"
    end
    assert_equal "4", ActionTracker::Record.first.params[:foo]
  end

  def test_track_actions_default_is_after
    ActionTrackerConfig.default_filter_time = :after
    @controller = create_controller { track_actions :some_verb }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => "4"
    end
    assert_equal 5, ActionTracker::Record.first.params[:foo]
  end

  def test_track_actions_default_is_before
    ActionTrackerConfig.default_filter_time = :before
    @controller = create_controller { track_actions :some_verb }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => "4"
    end
    assert_equal "4", ActionTracker::Record.first.params[:foo]
  end

  def test_track_actions_executes_block
    @controller = create_controller do
      track_actions :some_verb do
        throw :some_symbol
      end
    end
    assert_difference 'ActionTracker::Record.count' do
      assert_throws :some_symbol do
        get :index, :foo => "4"
      end
    end
    assert_equal "4", ActionTracker::Record.first.params[:foo]
  end

  def test_pass_keep_params_as_symbol
    @controller = create_controller { track_actions_before :some_verb, :keep_params => [:foo] }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5
    end
    assert_equal({ "foo" => "5" }, ActionTracker::Record.first.params)
  end

  def test_pass_keep_params_as_string
    @controller = create_controller { track_actions_before :some_verb, "keep_params" => [:foo, :bar] }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5, :bar => 10
    end
    assert_equal({ "foo" => "5", "bar" => "10" }, ActionTracker::Record.first.params)
  end

  def test_pass_keep_params_none
    @controller = create_controller { track_actions_before :some_verb, :keep_params => :none }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5
    end
    assert_equal({}, ActionTracker::Record.first.params)
    ActionTracker::Record.delete_all
		@controller = create_controller { track_actions_before :some_verb, :keep_params => "none" }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5
    end
    assert_equal({}, ActionTracker::Record.first.params)
  end

  def test_pass_keep_params_all
    @controller = create_controller { track_actions_before :some_verb, :keep_params => :all }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5
    end
    assert_equal({"action"=>"index", "foo"=>"5", "controller"=>"things"}, ActionTracker::Record.first.params)
    ActionTracker::Record.delete_all
    @controller = create_controller { track_actions_before :some_verb, :keep_params => "all" }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5
    end
    assert_equal({"action"=>"index", "foo"=>"5", "controller"=>"things"}, ActionTracker::Record.first.params)
	end

  def test_keep_params_not_set_should_store_all_params
    @controller = create_controller { track_actions_before :some_verb }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5
    end
    assert_equal({"action"=>"index", "foo"=>"5", "controller"=>"things"}, ActionTracker::Record.first.params)
  end

  def test_execute_if_some_condition_is_true
    @controller = create_controller { track_actions_before :some_verb, :if => Proc.new { 2 < 1 } }
    assert_no_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5
    end
    @controller = create_controller { track_actions_before :some_verb, :if => Proc.new { 2 > 1 } }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5
    end
  end

  def test_execute_unless_some_condition_is_true
    @controller = create_controller { track_actions_before :some_verb, :unless => Proc.new { 2 < 1 } }
    assert_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5
    end
    @controller = create_controller { track_actions_before :some_verb, :unless => Proc.new { 2 > 1 } }
    assert_no_difference 'ActionTracker::Record.count' do
      get :index, :foo => 5
    end
  end

  def test_execute_for_all_actions
    @controller = create_controller { track_actions_before :some_verb }
    assert_difference 'ActionTracker::Record.count' do
      get :index
    end
    assert_difference 'ActionTracker::Record.count' do
      get :test
    end
  end

  def test_execute_only_for_some_action
    @controller = create_controller { track_actions_before :some_verb, :only => [:index] }
    assert_difference 'ActionTracker::Record.count' do
      get :index
    end
    assert_no_difference 'ActionTracker::Record.count' do
      get :test
    end
  end

  def test_execute_except_for_some_action
    @controller = create_controller { track_actions_before :some_verb, :except => [:index] }
    assert_no_difference 'ActionTracker::Record.count' do
      get :index
    end
    assert_difference 'ActionTracker::Record.count' do
      get :test
    end
  end

  def test_store_user
    @controller = create_controller do
			track_actions_before :some_verb
		end
    ActionTrackerConfig.current_user = proc{ SomeModel.create! :some_column => "test" }

    assert_difference 'ActionTracker::Record.count' do
      get :test
    end
		assert_equal "test", ActionTracker::Record.last.user.some_column
  end

  def test_should_update_when_verb_is_updatable_and_no_timeout
    ActionTrackerConfig.verbs = { :some_verb => { :description => "Did something", :type => :updatable } }
    ActionTrackerConfig.timeout = 5.minutes
    @controller = create_controller { track_actions_before :some_verb }
    assert ActionTrackerConfig.verb_type(:some_verb) == :updatable
		assert_difference 'ActionTracker::Record.count' do
      get :test
    end
    t = ActionTracker::Record.last
    t.updated_at = t.updated_at.ago(2.minutes)
    t.send :update_without_callbacks
	  assert_no_difference 'ActionTracker::Record.count' do
      get :test
    end
  end

  def test_should_create_when_verb_is_updatable_and_timeout
    ActionTrackerConfig.verbs = { :some_verb => { :description => "Did something", :type => :updatable } }
    ActionTrackerConfig.timeout = 5.minutes
    @controller = create_controller { track_actions_before :some_verb }
    assert ActionTrackerConfig.verb_type(:some_verb) == :updatable
		assert_difference 'ActionTracker::Record.count' do
      get :test
    end
    t = ActionTracker::Record.last
    t.updated_at = t.updated_at.ago(6.minutes)
    t.send :update_without_callbacks
	  assert_difference 'ActionTracker::Record.count' do
      get :test
    end
  end

  def test_should_update_when_verb_is_groupable_and_no_timeout
    ActionTrackerConfig.verbs = { :some_verb => { :description => "Did something", :type => :groupable } }
    ActionTrackerConfig.timeout = 5.minutes
    @controller = create_controller { track_actions_before :some_verb, :keep_params => [:foo] }
    assert ActionTrackerConfig.verb_type(:some_verb) == :groupable
		assert_difference 'ActionTracker::Record.count' do
      get :test, :foo => "bar"
    end
    t = ActionTracker::Record.last
    t.updated_at = t.updated_at.ago(2.minutes)
    t.send :update_without_callbacks
	  assert_no_difference 'ActionTracker::Record.count' do
      get :test, :foo => "test"
    end
  end

  def test_should_create_when_verb_is_groupable_and_timeout
    ActionTrackerConfig.verbs = { :some_verb => { :description => "Did something", :type => :groupable } }
    ActionTrackerConfig.timeout = 5.minutes
    @controller = create_controller { track_actions_before :some_verb, :keep_params => [:foo] }
    assert ActionTrackerConfig.verb_type(:some_verb) == :groupable
		assert_difference 'ActionTracker::Record.count' do
      get :test, :foo => "bar"
    end
    t = ActionTracker::Record.last
    t.created_at = t.updated_at.ago(6.minutes)
    t.send :update_without_callbacks
	  assert_difference 'ActionTracker::Record.count' do
      get :test, :foo => "test"
    end
  end

  def test_should_create_when_verb_is_single
    ActionTrackerConfig.verbs = { :some_verb => { :description => "Did something", :type => :single } }
    @controller = create_controller { track_actions_before :some_verb }
    assert ActionTrackerConfig.verb_type(:some_verb) == :single
		assert_difference 'ActionTracker::Record.count' do
      get :test
    end
	  assert_difference 'ActionTracker::Record.count' do
      get :test
    end
  end

  def test_should_act_as_trackable
    m = SomeModel.create!
    assert m.respond_to?(:tracked_actions)
    assert_kind_of Array, m.tracked_actions
    @controller = create_controller { track_actions_before :some_verb }
    @controller.stubs(:current_user).returns(m)
    get :index
    sleep 2
    get :test
    assert ActionTracker::Record.last.updated_at > ActionTracker::Record.first.updated_at
    assert_equal [ActionTracker::Record.last, ActionTracker::Record.first], m.reload.tracked_actions
  end

  def test_should_get_time_spent_doing_something
    ActionTrackerConfig.verbs = { :some_verb => { :type => :updatable }, :other_verb => { :type => :updatable } }
    m = SomeModel.create!
    @controller = create_controller do
      track_actions :some_verb
    end
    @controller.stubs(:current_user).returns(m)
    get :index
    t1 = ActionTracker::Record.last
    t1.updated_at = t1.updated_at.ago(4.hours)
    t1.created_at = t1.updated_at.ago(3.hours)
    t1.send :update_without_callbacks
    get :test
    t2 = ActionTracker::Record.last
    t2.updated_at = t2.updated_at.ago(3.hours)
    t2.created_at = t2.updated_at.ago(2.hours)
    t2.send :update_without_callbacks
    assert_equal 5.hours, m.time_spent_doing(:some_verb)
    assert_equal 3.hours, m.time_spent_doing(:some_verb, :id => t1.id)
    assert_equal 0.0, m.time_spent_doing(:other_verb)
    assert_equal 0.0, m.time_spent_doing(:other_verb, :verb => :some_verb)
  end

  def test_helper_describe_action_tracker_object
    ActionTrackerConfig.verbs = { :some_verb => { :description => "Hey, {{link_to 'click here', :controller => :things}} {{ta.user.some_column}}!" } }
    view = ActionView::Base.new
    view.controller = @controller
    @request.env["HTTP_REFERER"] = "http://test.com"
    get :index
    user = SomeModel.create! :some_column => "test"
    t = ActionTracker::Record.create! :verb => :some_verb, :user => user
    assert_equal 'Hey, <a href="/things">click here</a> test!', view.describe(t)
  end

  def test_helper_describe_non_action_tracker_object
    view = ActionView::Base.new
    view.controller = @controller
    @request.env["HTTP_REFERER"] = "http://test.com"
    get :index
    assert_equal "", view.describe("Something")
  end

  def test_track_actions_store_user
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create
    end
    @controller = create_controller_for_model(model)
    assert_difference 'ActionTracker::Record.count' do
      get :test
    end
    assert_kind_of SomeModel, ActionTracker::Record.last.user
		assert_equal "test", ActionTracker::Record.last.user.some_column
  end

  def test_track_actions_store_some_params
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create, :keep_params => [:other_column]
    end
    @controller = create_controller_for_model(model, :other_column => "foo", :another_column => 2)
    assert_difference 'ActionTracker::Record.count' do
      get :test
    end
		assert_equal "foo", ActionTracker::Record.last.params["other_column"]
		assert_nil ActionTracker::Record.last.params["another_column"]
  end

  def test_replace_dots_by_underline_in_param_name
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create, :keep_params => ["other_column.size", :another_column]
    end
    @controller = create_controller_for_model(model, :other_column => "foo", :another_column => 5)
    assert_difference 'ActionTracker::Record.count' do
      get :test
    end
		assert_equal 3, ActionTracker::Record.last.params["other_column_size"]
		assert_equal 5, ActionTracker::Record.last.params["another_column"]
  end

  def test_track_actions_store_all_params
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create, :keep_params => :all
    end
    @controller = create_controller_for_model(model, :other_column => "foo", :another_column => 2)
    assert_difference 'ActionTracker::Record.count' do
      get :test
    end
		assert_equal "foo", ActionTracker::Record.last.params["other_column"]
		assert_equal 2, ActionTracker::Record.last.params["another_column"]
  end

  def test_track_actions_store_all_params_by_default
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create
    end
    @controller = create_controller_for_model(model, :other_column => "foo", :another_column => 2)
    assert_difference 'ActionTracker::Record.count' do
      get :test
    end
		assert_equal "foo", ActionTracker::Record.last.params["other_column"]
		assert_equal 2, ActionTracker::Record.last.params["another_column"]
  end

  def test_track_actions_store_no_params
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create, :keep_params => :none
    end
    @controller = create_controller_for_model(model, :other_column => "foo", :another_column => 2)
    assert_difference 'ActionTracker::Record.count' do
      get :test
    end
		assert_nil ActionTracker::Record.last.params["other_column"]
		assert_nil ActionTracker::Record.last.params["another_column"]
  end

  def test_track_actions_with_options
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model { track_actions :test, :after_create, :keep_params => :all, :if => Proc.new { 2 > 1 } }
    @controller = create_controller_for_model(model)
    assert_difference('ActionTracker::Record.count') { get :test }

    model = create_model { track_actions :test, :after_create, :keep_params => :all, :if => Proc.new { 2 < 1 } }
    @controller = create_controller_for_model(model)
    assert_no_difference('ActionTracker::Record.count') { get :test }

    model = create_model { track_actions :test, :after_create, :keep_params => :all, :unless => Proc.new { 2 > 1 } }
    @controller = create_controller_for_model(model)
    assert_no_difference('ActionTracker::Record.count') { get :test }

    model = create_model { track_actions :test, :after_create, :keep_params => :all, :unless => Proc.new { 2 < 1 } }
    @controller = create_controller_for_model(model)
    assert_difference('ActionTracker::Record.count') { get :test }
  end

  def test_track_actions_post_processing_as_symbol
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create, :post_processing => Proc.new { |ta| OtherModel.create!(:other_column => ta.verb) }
    end
    @controller = create_controller_for_model(model, :another_column => 2)
    assert_difference 'ActionTracker::Record.count' do
      assert_difference('OtherModel.count', 2) do
        get :test
      end
    end
		assert_equal "test", OtherModel.last.other_column
  end

  def test_track_actions_post_processing_as_string
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create, "post_processing" => Proc.new { |ta| OtherModel.create!(:other_column => ta.verb) }
    end
    @controller = create_controller_for_model(model, :another_column => 2)
    assert_difference 'ActionTracker::Record.count' do
      assert_difference('OtherModel.count', 2) do
        get :test
      end
    end
    assert_equal "test", OtherModel.last.other_column
  end

  def test_track_actions_custom_user_as_symbol
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create, :custom_user => :test_custom_user
      def test_custom_user
        OtherModel.create!
      end
    end
    ActionTrackerConfig.current_user = proc{ SomeModel.create! }
    @controller = create_controller_for_model(model, :another_column => 2)
    assert_difference('ActionTracker::Record.count') { get :test }
		assert_kind_of OtherModel, ActionTracker::Record.last.user
  end

  def test_track_actions_custom_user_as_string
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create, "custom_user" => :test_custom_user
      def test_custom_user
        OtherModel.create!
      end
    end
    ActionTrackerConfig.current_user = proc{ SomeModel.create! }
    @controller = create_controller_for_model(model, :another_column => 2)
    assert_difference('ActionTracker::Record.count') { get :test }
		assert_kind_of OtherModel, ActionTracker::Record.last.user
  end

  def test_track_actions_custom_user_is_nil_by_default
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create
      def test_custom_user
        OtherModel.create!
      end
    end
    ActionTrackerConfig.current_user = proc{ SomeModel.create! }
    @controller = create_controller_for_model(model, :another_column => 2)
    assert_difference('ActionTracker::Record.count') { get :test }
		assert_kind_of SomeModel, ActionTracker::Record.last.user
  end

  def test_track_actions_custom_target_as_symbol
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create, :custom_target => :test_custom_target
      def test_custom_target
        SomeModel.create!
      end
    end
    @controller = create_controller_for_model(model, :another_column => 2)
    assert_difference('ActionTracker::Record.count') { get :test }
		assert_kind_of SomeModel, ActionTracker::Record.last.target
  end

  def test_track_actions_custom_target_as_string
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create, "custom_target" => :test_custom_target
      def test_custom_target
        SomeModel.create!
      end
    end
    @controller = create_controller_for_model(model, :another_column => 2)
    assert_difference('ActionTracker::Record.count') { get :test }
		assert_kind_of SomeModel, ActionTracker::Record.last.target
  end

  def test_acts_as_trackable_with_options
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    @@action = create_model do
      track_actions :test, :after_create
    end
    @@user = create_model do
      acts_as_trackable :after_add => Proc.new { |x, y| raise 'I was called' }
    end
    @controller = create_controller do
      def test
        @@action.create!
        render :text => "test"
      end
			def current_user
				@@user.create!
			end
		end
    assert_raise(RuntimeError, 'I was called') do
      get :test
    end
  end

  def test_track_actions_save_target
    ActionTrackerConfig.verbs = { :test => { :description => "Some" } }
    model = create_model do
      track_actions :test, :after_create
    end
    @controller = create_controller_for_model(model)
    assert_difference 'ActionTracker::Record.count' do
      get :test
    end
    assert_kind_of model.base_class, ActionTracker::Record.last.target
  end

  private

	def create_controller(&block)
    klass = Class.new(ThingsController)
    klass.module_eval &block
    klass.stubs(:controller_path).returns('things')
    klass.new
  end

  def create_model(&block)
    klass = Class.new(OtherModel)
    klass.module_eval &block
    klass
  end

  def create_controller_for_model(model, attributes = {})
    @@model, @@attributes = model, attributes
    create_controller do
      def test
        @@model.create! @@attributes
        render :text => "test"
      end

		end
    ActionTrackerConfig.current_user = proc{ SomeModel.create! :some_column => "test" }
  end

end
