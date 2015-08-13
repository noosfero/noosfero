require_dependency 'article'

class Article

  after_update :open_graph_scrape

  protected

  def open_graph_scrape
    activity = OpenGraphPlugin::Activity.where(object_data_id: self.id, object_data_type: self.class.base_class.name).first
    activity.scrape if activity
  end
  handle_asynchronously :open_graph_scrape

end
