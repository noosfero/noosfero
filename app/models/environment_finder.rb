class EnvironmentFinder
  
  def initialize env
    @environment = env
  end

  def find(asset, query)
    @environment.send(asset).find_by_contents(query)
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
