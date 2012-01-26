if ActiveRecord::Base.instance_methods.include?("touch") && Class.const_defined?('TOUCH_LOADED')
  puts "W: ActiveRecord already provides a touch method, which means you must be using rails 2.3.3 or later."
  puts "W: In this case the touch plugin could probably be removed"
end
TOUCH_LOADED = true

module Touch
  def touch
    update_attribute(:updated_at, Time.now)
  end
end

ActiveRecord::Base.send(:include, Touch)
