module BoxOrganizerHelper

  def icon_selector(icon = 'no-ico')
    render :partial => 'icon_selector', :locals => { :icon => icon }
  end

  def extra_option_checkbox(option)
    if [:human_name, :name, :value, :checked, :options].all? {|k| option.key? k}
      labelled_check_box(option[:human_name], option[:name], option[:value], option[:checked], option[:options])
    end
  end

end