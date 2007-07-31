class ActiveRecord::Base

  # declares an ActiveRecord class to be a design. The class is automatically
  # associated with a +has_many+ relationship to Design::Box.
  #
  # The underlying database table *must* have a column named +design_data+ of
  # type +text+. +string+ should work too, but you may run into problems
  # related to length limit, so unless you have a very good reason not to, use
  # +text+ type.
  #
  # +acts_as_design+ adds the following methods to your model (besides a
  # +has_many :boxes+ relationship).
  #
  # * template
  # * template=(value)
  # * theme
  # * theme=(value)
  # * icon_theme
  # * icon_theme(value)
  #
  # All these virtual attributes will return <tt>'default'</tt> if set to +nil+
  def self.acts_as_design
    has_many :boxes, :class_name => 'Design::Box', :as => :owner

    serialize :design_data
    attr_protected :design_data

    after_create do |design|
      template = Design::Template.find(design.template)
      while design.boxes.size < template.number_of_boxes
        design.boxes << Design::Box.new(:name => 'Block')
      end
    end

    def design_data
      self[:design_data] ||= Hash.new
    end
    
    def template # :nodoc:
      self.design_data[:template] || 'default'
    end

    def template=(value) # :nodoc:
      self.design_data[:template] = value
    end

    def theme # :nodoc:
      self.design_data[:theme] || 'default'
    end

    def theme=(value) # :nodoc:
      self.design_data[:theme] = value
    end

    def icon_theme # :nodoc:
      self.design_data[:icon_theme] || 'default'
    end

    def icon_theme=(value) # :nodoc:
      self.design_data[:icon_theme] = value
    end
  end
end
