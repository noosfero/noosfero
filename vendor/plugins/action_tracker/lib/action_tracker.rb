require File.join(File.dirname(__FILE__), 'action_tracker_model.rb')

module ActionTracker

  module ControllerMethods

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def track_actions_after(verb, options = {}, &block)
        track_actions_by_time(verb, :after, options, &block)
      end

      def track_actions_before(verb, options = {}, &block)
        track_actions_by_time(verb, :before, options, &block)
      end

      def track_actions(verb, options = {}, &block)
        track_actions_by_time(verb, ActionTrackerConfig.default_filter_time, options, &block)
      end

      def track_actions_by_time(verb, time, options = {}, &block)
        keep_params = options.delete(:keep_params) || options.delete('keep_params') || :all
        send("#{time}_filter", options) do |x|
          x.save_action_for_verb(verb.to_s, keep_params)
          block.call(x) unless block.nil?
        end
        send :include, InstanceMethods
      end
    end

    module InstanceMethods
      def save_action_for_verb(verb, keep_params = :all)
        if keep_params.is_a? Array
          stored_params = params.reject { |key, value| !keep_params.include?(key.to_sym) and !keep_params.include?(key.to_s) }
        elsif keep_params.to_s == 'none'
          stored_params = {}
        elsif keep_params.to_s == 'all'
          stored_params = params
        end
        user = send ActionTrackerConfig.current_user
        tracked_action = case ActionTrackerConfig.verb_type(verb)
          when :groupable
            Record.add_or_create :verb => verb, :user => user, :params => stored_params
          when :updatable
            Record.update_or_create :verb => verb, :user => user, :params => stored_params
          when :single
            Record.new :verb => verb, :user => user, :params => stored_params
        end
        user.tracked_actions << tracked_action
      end
    end

  end

  module ModelMethods

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def track_actions(verb, callback, options = {}, &block)
        keep_params = options.delete(:keep_params) || options.delete('keep_params') || :all
        post_proc = options.delete(:post_processing) || options.delete('post_processing') || Proc.new{}
        custom_user = options.delete(:custom_user) || options.delete('custom_user') || nil
        custom_target = options.delete(:custom_target) || options.delete('custom_target') || nil
        send(callback, Proc.new { |tracked| tracked.save_action_for_verb(verb.to_s, keep_params, post_proc, custom_user, custom_target) }, options)
        send :include, InstanceMethods
      end

      def acts_as_trackable(options = {})
        has_many :tracked_actions, -> { order 'updated_at DESC' },
          {class_name: "ActionTracker::Record", foreign_key: :user_id, dependent: :destroy }.merge(options)
        send :include, InstanceMethods
      end
    end

    module InstanceMethods
      def time_spent_doing(verb, conditions = {})
        time = 0
        tracked_actions.where(conditions.merge verb: verb.to_s).each do |t|
          time += t.updated_at - t.created_at
        end
        time.to_f
      end

      def save_action_for_verb(verb, keep_params = :all, post_proc = Proc.new{}, custom_user = nil, custom_target = nil)
        user = self.send(custom_user) unless custom_user.blank?
        user ||= ActionTracker::Record.current_user
        target = self.send(custom_target) unless custom_target.blank?
        return nil if user.nil?
        if keep_params.is_a? Array
          stored_params = {}
          keep_params.each do |param|
            result = self
            param.to_s.split('.').each { |m| result = result.send(m) }
            stored_params[param.to_s.gsub(/\./, '_')] = result
          end
        elsif keep_params.to_s == 'none'
          stored_params = {}
        elsif keep_params.to_s == 'all'
          stored_params = self.attributes
        end
        tracked_action = case ActionTrackerConfig.verb_type(verb)
          when :groupable
            Record.add_or_create :verb => verb, :params => stored_params, :user => user, :target => target
          when :updatable
            Record.update_or_create :verb => verb, :params => stored_params, :user => user, :target => target
          when :single
            Record.new :verb => verb, :params => stored_params, :user => user
        end
        tracked_action.target = target || self
        user.tracked_actions << tracked_action
        post_proc.call tracked_action
      end

    end

  end

  module ViewHelper
    def describe(ta)
      send "#{ta.verb}_description", ta if ta.is_a? ActionTracker::Record
    end
  end

end

ActionController::Base.send :include, ActionTracker::ControllerMethods
ActiveRecord::Base.send :include, ActionTracker::ModelMethods
ActionView::Base.send :include, ActionTracker::ViewHelper
