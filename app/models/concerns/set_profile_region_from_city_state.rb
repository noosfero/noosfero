module SetProfileRegionFromCityState

  module ClassMethods
    def set_profile_region_from_city_state
      before_save :region_from_city_and_state
      include InstanceMethods
    end
  end

  module InstanceMethods
    include Noosfero::Plugin::HotSpot

    def city=(value)
      super
      @change_region = true
    end

    def state=(value)
      super
      @change_region = true
    end

    def region_from_city_and_state
      if @change_region
        self.region = nil
        state = search_region(State, self.state)
        if state
          self.region = search_region(City.where(:parent_id => state.id), self.city)
        end
      end
    end

    private

    def search_region(scope, query)
      return nil if !query
      query = query.downcase.strip
      scope.where(['lower(name)=? OR lower(abbreviation)=? OR lower(acronym)=?', query, query, query]).first
    end
  end

end
