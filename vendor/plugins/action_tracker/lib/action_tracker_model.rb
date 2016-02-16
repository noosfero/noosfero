module ActionTracker
  class Record < ActiveRecord::Base
    attr_accessible :verb, :params, :user, :target

    self.table_name = 'action_tracker'

    belongs_to :user, :polymorphic => true
    belongs_to :target, :polymorphic => true

    serialize :params, Hash

    before_validation :stringify_verb

    validates_presence_of :verb
    validates_presence_of :user
    validate :user_existence

    def user_existence
      errors.add(:user, "user doesn't exists") if user && !user.class.exists?(user)
    end

    alias_method :subject, :user

    # In days
    RECENT_DELAY = 30

    scope :recent, -> { where 'created_at >= ?', RECENT_DELAY.days.ago }
    scope :visible, -> { where visible: true }

    def self.current_user
      ActionTrackerConfig.current_user.call
    end

    def self.update_or_create(params)
      u = params[:user] || current_user
      return if u.nil?
      target_hash = params[:target].nil? ? {} : {:target_type => params[:target].class.base_class.to_s, :target_id => params[:target].id}
      conditions = { :user_id => u.id, :user_type => u.class.base_class.to_s, :verb => params[:verb].to_s }.merge(target_hash)
      l = where(conditions).last
      ( !l.nil? and Time.now - l.updated_at < ActionTrackerConfig.timeout ) ? l.update(params.merge({ :updated_at => Time.now })) : l = new(params)
      l
    end

    def self.add_or_create(params)
      u = params[:user] || current_user
      return if u.nil?
      target_hash = params[:target].nil? ? {} : {:target_type => params[:target].class.base_class.to_s, :target_id => params[:target].id}
      l = where({user_id: u.id, user_type: u.class.base_class.to_s, verb: params[:verb].to_s}.merge target_hash).last
      if !l.nil? and Time.now - l.created_at < ActionTrackerConfig.timeout
        params[:params].clone.each { |key, value| params[:params][key] = l.params[key].clone.push(value) }
        l.update params
      else
        params[:params].clone.each { |key, value| params[:params][key] = [value] }
        l = new params
      end
      l
    end

    def self.time_spent(conditions = {}) # In seconds
      #FIXME Better if it could be completely done in the database, but SQLite does not support difference between two timestamps
      time = 0
      self.where(conditions).each{ |action| time += action.updated_at - action.created_at }
      time.to_f
    end

    def duration # In seconds
      ( updated_at - created_at ).to_f
    end

    def description
      text = ActionTrackerConfig.get_verb(self.verb)[:description] || ""
      if text.is_a?(Proc)
        self.instance_eval(&text)
      else
        text
      end
    end

    def describe
      description.gsub(/\{\{([^}]+)\}\}/) { eval $1 }
    end

    def predicate
      self.params || {}
    end

    def phrase
      { :subject => self.subject, :verb => self.verb, :predicate => self.predicate }
    end

    def method_missing(method, *args, &block)
      if method.to_s =~ /^get_(.*)$/
        param = method.to_s.gsub('get_', '')
        predicate[param.to_s] || predicate[param.to_sym]
      else
        super
      end
    end

    def collect_group_with_index(param)
      send("get_#{param}").collect.with_index{ |el, i| yield el, i }
    end

    protected

    def validate
      errors.add_to_base "Verb must be one of the following: #{ActionTrackerConfig.verb_names.join(',')}" unless ActionTrackerConfig.verb_names.include?(self.verb)
    end

    private

    def stringify_verb
      self.verb = self.verb.to_s unless self.verb.nil?
    end

  end
end
