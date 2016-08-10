module ElasticsearchPluginHelper

  def categories_data(collection)
    result = []
    collection.each do | item |
      result.push({ text: item.name, id: item.id })
      result.last[:children] = categories_data(item.children) if item.children_count > 0
    end
    result
  end
end
