require_relative '../nested_helper/environment'

module Filter

  def self.included base
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods

    def filter options={}

      result_filter = {}
      result_filter[:indices] = {:index => self.index_name, :no_match_filter => "none" }
      result_filter[:indices][:filter] = { :bool => self.filter_bool(options)  }

      result_filter
    end

    def filter_bool options={}
      environment = options[:environment].presence
      user = options[:user].presence

      result_filter = {}

      result_filter[:must] = [ NestedEnvironment::filter(environment) ]

      return result_filter if user and user.person.is_admin?

      self.nested_filter.each {|filter| result_filter[:must].append(filter)}  if self.respond_to? :nested_filter
      self.must.each          {|filter| result_filter[:must].append(filter) } if self.respond_to? :must

      result_filter[:should]    = self.should    if self.respond_to? :should
      result_filter[:must_not]  = self.must_not  if self.respond_to? :must_not

      result_filter
    end

    def filter_category selected_categories
      {
        query: {
          terms: { category_ids: selected_categories }
        }
      }
    end

  end

  module InstanceMethods

  end

end
