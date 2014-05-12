module MapsHelper
  def self.search_city term, state=""
    cities = if state.empty?
      NationalRegion.search_city(term + "%", true)
    else
      NationalRegion.search_city(term + "%", true, state)
    end
    cities.map {|r|{ :label => r.city , :category => r.state}}
  end

  def self.search_state term
    NationalRegion.search_state(term + "%", true).map {|r|{ :label => r.state}}
  end
end
