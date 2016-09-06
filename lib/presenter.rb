class Presenter
  # Define presenter base_class
  def self.base_class
  end

  # Define base type condition
  def self.available?(instance)
    false
  end

  def self.for(instance)
    return instance if instance.is_a?(Presenter) || !available?(instance)

    klass = subclasses.sort_by {|class_instance|
      class_instance.accepts?(instance) || 0
    }.last

    klass.accepts?(instance) ? klass.new(instance) : f
  end

  def initialize(instance)
    @instance = instance
  end

  # Allows to use the original instance reference.
  def encapsulated_instance
    @instance
  end

  def id
    @instance.id
  end

  def reload
    @instance.reload
    self
  end

  def kind_of?(klass)
    @instance.kind_of?(klass)
  end

  # This method must be overridden in subclasses.
  #
  # If the class accepts the instance, return a number that represents the
  # priority the class should be given to handle that instance. Higher numbers
  # mean higher priority.
  #
  # If the class does not accept the instance, return false.
  def self.accepts?(f)
    nil
  end

  # That makes the presenter to works like any other not encapsulated instance.
  def method_missing(m, *args)
    @instance.send(m, *args)
  end
end

# Preload Presenters to allow `Presenter.for()` to work
Dir.glob(File.join('app', 'presenters', '*.rb')) do |file|
  load file
end
