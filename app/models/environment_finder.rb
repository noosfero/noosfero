class EnvironmentFinder
  
  def initialize env
    @environment = env
  end

  def articles(query='*', options = {})
    @environment.articles.find_by_contents(query, {}, options)
  end
  
  def people(query='*', options = {})
    @environment.people.find_by_contents(query, {}, options)
  end
  
  def communities(query='*', options = {})
    @environment.communities.find_by_contents(query, {}, options)
  end
  
  def products(query='*', options = {})
    @environment.products.find_by_contents(query, {}, options)
  end
  
  def enterprises(query='*', options = {})
    @environment.enterprises.find_by_contents(query, {}, options)
  end
  
  def comments(query='*', options = {})
    @environment.comments.find_by_contents(query, {}, options)
  end

  def recent(asset, limit = 10)
    with_options :limit => limit, :order => 'created_at desc, id desc' do |finder|
      finder.send(asset, '*', {})
    end
  end

  def count(asset)
    @environment.send(asset).count
  end

end
