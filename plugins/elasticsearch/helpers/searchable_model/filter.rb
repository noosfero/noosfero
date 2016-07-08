require_relative '../nested_helper/environment'

module Filter

  def self.included base
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods

    def filter options={}
      environment = options[:environment].presence

      result_filter = {}
      result_filter[:indices] = {:index => self.index_name, :no_match_filter => "none" }
      result_filter[:indices][:filter] = { :bool => self.filter_bool(environment)  }

      result_filter
    end

    def filter_bool environment
      result_filter = {}

      result_filter[:must] = [ NestedEnvironment::environment_filter(environment) ]

      self.nested_filter.each {|filter| result_filter[:must].append(filter)}  if self.respond_to? :nested_filter
      self.must.each          {|filter| result_filter[:must].append(filter) } if self.respond_to? :must

      result_filter[:should]    = self.should    if self.respond_to? :should
      result_filter[:must_not]  = self.must_not  if self.respond_to? :must_not

      result_filter
    end


  end

  module InstanceMethods

  end

end
