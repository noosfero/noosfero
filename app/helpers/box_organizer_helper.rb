module BoxOrganizerHelper

  def icon_selector(icon = 'no-ico')
    render :partial => 'icon_selector', :locals => { :icon => icon }
  end

end
