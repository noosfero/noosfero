module ContainerBlockPluginController

  def saveWidths
    container = boxes_holder.blocks.find(params[:id])
    pairs = params[:widths].split('|')
    settings = container.children_settings
    pairs.each do |pair|
      id, width = pair.split(',')
      settings[id.to_i] = {:width => width.to_i}
    end
    container.children_settings = settings
    container.save!

    render :text => _('Block successfully saved.')
  end

end
