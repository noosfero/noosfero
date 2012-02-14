module SetProfileRegionFromCityState

  module ClassMethods
    def set_profile_region_from_city_state
      before_save :region_from_city_and_state

      include InstanceMethods
    end
  end

  module InstanceMethods

    def city=(value)
      self.data[:city] = value
      @change_region = true
    end

    def state=(value)
      self.data[:state] = value
      @change_region = true
    end

    def region_from_city_and_state
      if @change_region
        s = State.find_by_name self.state
        c = s.children.find_by_name self.city
        self.region = c
      end
    end

  end

end
