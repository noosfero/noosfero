module ContainerBlockPluginController
  
  def saveWidths
    container = boxes_holder.blocks.find(params[:id])
    pairs = params[:widths].split('|')
    settings = {}
    pairs.each do |pair|
      id, width = pair.split(',')
      settings[id.to_i] = {:width => width}
    end
    container.children_settings = settings
    container.save!
    render :json => {:ok => true}
  end

end
