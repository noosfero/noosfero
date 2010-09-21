module UserStamp
  mattr_accessor :creator_attribute
  mattr_accessor :updater_attribute
  mattr_accessor :current_user_method
  
  def self.creator_assignment_method
    "#{UserStamp.creator_attribute}="
  end
  
  def self.updater_assignment_method
    "#{UserStamp.updater_attribute}="
  end
  
  module ClassMethods
    def user_stamp(*models)
      models.each { |klass| klass.add_observer(UserStampSweeper.instance) }
      
      class_eval do
        cache_sweeper :user_stamp_sweeper
      end
    end
  end
end

UserStamp.creator_attribute   = :creator_id
UserStamp.updater_attribute   = :updater_id
UserStamp.current_user_method = :current_user

class UserStampSweeper < ActionController::Caching::Sweeper
  def before_validation(record)
    return unless current_user
    
    attribute, method = UserStamp.creator_attribute, UserStamp.creator_assignment_method
    if record.respond_to?(method) && record.new_record?
      record.send(method, current_user) unless record.send("#{attribute}_id_changed?") || record.send("#{attribute}_type_changed?")
    end
    
    attribute, method = UserStamp.updater_attribute, UserStamp.updater_assignment_method
    if record.respond_to?(method)
      record.send(method, current_user) if record.send(attribute).blank?
    end
  end
  
  private  
    def current_user
      if controller.respond_to?(UserStamp.current_user_method)
        controller.send UserStamp.current_user_method
      end
    end
end
