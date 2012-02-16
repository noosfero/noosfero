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
        s = State.find_by_name self.state
        c = s.children.find_by_name self.city
        self.region = c
      end
    end

  end

end
