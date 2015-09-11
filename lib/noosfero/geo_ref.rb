module Noosfero::GeoRef

  # May replace this module by http://www.postgresql.org/docs/9.3/static/earthdistance.html

  EARTH_RADIUS = 6378 # aproximate in km

  class << self

    def dist(lat1, lng1, lat2, lng2)
      def deg2rad(d); (d*Math::PI)/180; end
      def c(n); Math.cos(n); end
      def s(n); Math.sin(n); end
      lat1 = deg2rad lat1
      lat2 = deg2rad lat2
      dlng = deg2rad(lng2) - deg2rad(lng1)
      EARTH_RADIUS * Math.atan2(
        Math.sqrt(
          ( c(lat2) * s(dlng) )**2 +
          ( c(lat1) * s(lat2) - s(lat1) * c(lat2) * c(dlng) )**2
        ),
        s(lat1) * s(lat2) + c(lat1) * c(lat2) * c(dlng)
      )
    end

    # Write a SQL expression to return the distance from a profile to a
    # reference point, in kilometers.
    # http://www.plumislandmedia.net/mysql/vicenty-great-circle-distance-formula
    def sql_dist(ref_lat, ref_lng)
      "2*PI()*#{EARTH_RADIUS}*(
        DEGREES(
          ATAN2(
            SQRT(
              POW(COS(RADIANS(#{ref_lat}))*SIN(RADIANS(#{ref_lng}-lng)),2) +
              POW(
                COS(RADIANS(lat)) * SIN(RADIANS(#{ref_lat})) - (
                  SIN(RADIANS(lat)) * COS(RADIANS(#{ref_lat})) * COS(RADIANS(#{ref_lng}-lng))
                ), 2
              )
            ),
            SIN(RADIANS(lat)) * SIN(RADIANS(#{ref_lat})) +
            COS(RADIANS(lat)) * COS(RADIANS(#{ref_lat})) * COS(RADIANS(#{ref_lng}-lng))
          )
        )/360
      )"
    end

    # Asks Google for the georef of a location.
    def location_to_georef(location)
      key = location.downcase
      ll = Rails.cache.read key
      return ll + [:CACHE] if ll.kind_of? Array
      resp = RestClient.get 'https://maps.googleapis.com/maps/api/geocode/json?' +
                            'sensor=false&address=' + url_encode(location)
      if resp.nil? || resp.code.to_i != 200
        if ENV['RAILS_ENV'] == 'test'
          print " Google Maps API fail (code #{resp ? resp.code : :nil}) "
        else
          Rails.logger.warn "Google Maps API request information for " +
                            "\"#{location}\" fail. (code #{resp ? resp.code : :nil})"
        end
        return [ 0, 0, "HTTP_FAIL_#{resp.code}".to_sym ] # do not cache failed response
      else
        json = JSON.parse resp.body
        if json && (r=json['results']) && (r=r[0]) && (r=r['geometry']) &&
           (r=r['location']) && r['lat']
          ll = [ r['lat'], r['lng'], :SUCCESS ]
        else
          status = json['status'] || 'Undefined Error'
          message = "Google Maps API cant find \"#{location}\" (#{status})"
          if ENV['RAILS_ENV'] == 'test'
            print " #{message} "
          else
            Rails.logger.warn message
          end
          ll = [ 0, 0, status.to_sym ]
        end
        Rails.cache.write key, ll
      end
      ll
    end

  end

end
