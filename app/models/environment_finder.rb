class EnvironmentFinder
  
  def initialize env
    @environment = env
  end

  def find(asset, query, options={})
   @region = Region.find_by_id(options.delete(:region)) if options.has_key?(:region)
    if @region && options[:within]
      options[:origin] = [@region.lat, @region.lng]
    else
      options.delete(:within)
    end
    @environment.send(asset).find_by_contents(query, {}, options)
  end

  def recent(asset, limit = 10)
    with_options :limit => limit, :order => 'created_at desc, id desc' do |finder|
      @environment.send(asset).recent(limit)
    end
  end

  def find_by_initial(asset, initial)
    @environment.send(asset).find_by_initial(initial)
  end

  def count(asset)
    @environment.send(asset).count
  end

end
