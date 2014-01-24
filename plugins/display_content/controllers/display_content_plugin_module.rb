module DisplayContentPluginController

  def index
    block = boxes_holder.blocks.find(params[:block_id])

    articles = block.articles_of_parent(params[:id])
    data = []
    data =  data + get_node(block, articles)
    render :json => data
  end

  protected

  def get_node(block, articles)
      nodes = []
      articles.map do |article|
        node = {}
        node[:data] = article.title
        node[:attr] = { 'node_id' => article.id, 'parent_id' => article.parent_id}
        if block.nodes.include?(article.id)
          node[:attr].merge!('class' => 'jstree-checked')
        elsif block.parent_nodes.include?(article.id)
          node[:children] = get_node(block, article.children)
          node[:attr].merge!('class' => 'jstree-undetermined')
        end
        node[:state] = 'closed' if Article.exists?(:parent_id => article.id)
        nodes.push(node)
     end
     nodes
  end

end
