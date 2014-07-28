class NationalRegion < ActiveRecord::Base

  SEARCHABLE_FIELDS = {
    :name => {:label => _('Name'), :weight => 1},
    :national_region_code => {:label => _('Region Code'), :weight => 1},
  }

  def self.search_city(city_name, like = false, state = nil)

    operator = "="
    find_return = :first
    adtional_contions = "";

    if like
     operator  = "ilike"
     find_return = :all
    end

    if state
      adtional_contions = " AND nr.name = :state "
    end


    conditions  = ["national_regions.name #{operator} :name AND
                    national_regions.national_region_type_id = :type" + adtional_contions,
                  {:name => city_name ,
                   :type => NationalRegionType::CITY,
                   :state => state}];

    region = NationalRegion.find(find_return,
                                  :select => "national_regions.name as city, nr.name as state, national_regions.national_region_code",
                                  :conditions => conditions,
                                  :joins => "LEFT JOIN national_regions as nr ON  national_regions.parent_national_region_code = nr.national_region_code",
                                  :limit => 10
                                  )
    return region
  end

  def self.search_state(state_name, like = false)
    operator = "="
    find_return = :first

    if like
     operator  = "ilike"
     find_return = :all
    end

     conditions  = ["national_regions.name #{operator} :name AND
                    national_regions.national_region_type_id = :type",
                  {:name => state_name,
                   :type => NationalRegionType::STATE}];

    region = NationalRegion.find(find_return,
                                  :select => "national_regions.name as state, national_regions.national_region_code",
                                  :conditions => conditions,
                                  :limit => 10
                                  )
    return region
   end

  def self.validate!(city, state, country)

    country_region = NationalRegion.find_by_national_region_code(country,
                                                :conditions => ["national_region_type_id = :type",
                                                               {:type => NationalRegionType::COUNTRY}])

    if(country_region)

      nregion = NationalRegion.search_city(city, false, state);

      if nregion == nil
        raise _('Invalid city or state name.')
      end

    end

    return nregion

  end

end
