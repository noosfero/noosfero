module Design

  # This class uses an external holder object to hold the details of the
  # design, and proxies all access to the template data to it. This object can
  # be any object that responds to the following methods:
  #
  # * +template+
  # * +template=+
  # * +theme+
  # * +theme=+
  # * +icon_theme+
  # * +icon_theme=+
  # * +boxes+
  # * +boxes=+
  #
  # These methods must implement get/set semantics for atrributes with their
  # names, and can be implemented with +attr_accessor+, as ActiveRecord
  # columns, or event explicity by writing the methods and storing the values
  # wherever you want.
  # 
  # +template+, +theme+ and +icon_theme+ must return (and accept in the
  # setters) strings, while +boxes+ must be an array of Box objects.
  class ProxyDesignHolder

    attr_reader :holder

    # creates a new proxy for +holder+
    def initialize(holder)
      @holder = holder
    end

    # proxies all calls to +template+, +theme+, +icon_theme+ and +boxes+ (as
    # well as their setters counterparts) to the holder object
    def method_missing(method_id, *args)
      if method_id.to_s =~ /^(template|theme|icon_theme|boxes)=?$/
        holder.send(method_id, *args)
      else
        raise NoMethodError.new("Design has no method \"#{method_id}\"")
      end
    end
  end

end
