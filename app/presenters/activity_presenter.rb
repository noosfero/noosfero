class ActivityPresenter < Presenter
  def self.base_class
    ActionTracker::Record
  end

  def self.available?(instance)
    instance.kind_of?(ActionTracker::Record) || instance.kind_of?(ProfileActivity)
  end

  def self.target(instance)
    if instance.kind_of?(ProfileActivity)
      target(instance.activity)
    elsif instance.kind_of?(ActionTracker::Record)
       instance.target
    else
      instance
    end
  end

  def self.owner(instance)
    instance.kind_of?(ProfileActivity) ? instance.profile : instance.user
  end

  def target
    self.class.target(encapsulated_instance)
  end

  def owner
    self.class.owner(encapsulated_instance)
  end

  def hidden_for?(user)
    (target.respond_to?(:display_to?) &&
     !target.display_to?(user)) ||
    !AccessLevels.can_access?(target_profile.wall_access, user, target_profile) ||
    !target_profile.allow_followers?
  end

  def involved?(user)
    owner == user || target == user
  end

  private

  def target_profile
    if target.is_a? Profile
      target
    elsif target.is_a? Article
      target.profile
    elsif target.is_a? Scrap
      target.receiver
    else
      owner
    end
  end
end

# Preload ActivityPresenter subclasses to allow `Presenter.for()` to work
Dir.glob(File.join('app', 'presenters', 'activity', '*.rb')) do |file|
  load file
end
