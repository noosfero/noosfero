module SetProfileRegionFromCityState

  module ClassMethods
    def set_profile_region_from_city_state
      before_save :region_from_city_and_state

      include InstanceMethods
      alias_method_chain :city=, :region
      alias_method_chain :state=, :region
    end
  end

  module InstanceMethods
    include Noosfero::Plugin::HotSpot

    def city_with_region=(value)
      self.city_without_region = value
      @change_region = true
    end

    def state_with_region=(value)
      self.state_without_region = value
      @change_region = true
    end

    def region_from_city_and_state
      if @change_region
        s = plugins.first(:find_by_contents, State, self.state)[:results].first
        if s
          c = plugins.first(:find_by_contents, City, self.city, {}, {:filter_queries => ["parent_id:#{s.id}"]})[:results].first
          self.region = c
        else
          self.region = nil
        end
      end
    end

  end

end
