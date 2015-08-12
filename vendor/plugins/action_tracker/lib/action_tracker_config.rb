class ActionTrackerConfig

  def self.config
    @action_tracker_config ||= {}
  end

  def self.config=(h)
    @action_tracker_config = h
  end

  def self.verbs
    config[:verbs] || {}
  end

  def self.verbs=(h)
    config[:verbs] = h
  end

  def self.verb_names
    verbs.keys.map(&:to_s)
  end

  def self.current_user
    config[:current_user] || proc{ nil }
  end

  def self.current_user= block
    config[:current_user] = block
  end

  def self.default_filter_time
    config[:default_filter_time] || :after
  end

  def self.default_filter_time=(before_or_after)
    config[:default_filter_time] = before_or_after
  end

  def self.timeout
    config[:timeout] || 5.minutes
  end

  def self.timeout=(seconds)
    config[:timeout] = seconds
  end

  def self.get_verb(verb)
    verbs[verb.to_s] || verbs[verb.to_sym] || {}
  end

  def self.verb_type(verb)
    type = get_verb(verb.to_s)[:type] || get_verb(verb.to_s)['type'] || :single
    verb_types.include?(type.to_sym) ? type : :single
  end

  def self.verb_types
    [:single, :updatable, :groupable]
  end

end
