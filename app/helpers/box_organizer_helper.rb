module BoxOrganizerHelper

  def display_icon(block)
    image_path = nil
    plugin = @plugins.fetch_first_plugin(:has_block?, block)

    theme = Theme.new(environment.theme) # remove this
    if File.exists?(File.join(theme.filesystem_path, block.icon_path))
      image_path = File.join(theme.public_path, block.icon_path)
    elsif plugin && File.exists?(File.join(Rails.root, 'public', plugin.public_path, block.icon_path))
      image_path = File.join('/', plugin.public_path, block.icon_path)
    elsif File.exists?(File.join(Rails.root, 'public', block.icon_path))
      image_path = block.icon_path
    else
      image_path = block.default_icon_path
    end

    image_tag(image_path, height: '48', width: '48', class: 'block-type-icon', alt: '' )
  end

  def display_previews(block)
    images_path = nil
    plugin = @plugins.fetch_first_plugin(:has_block?, block)

    theme = Theme.new(environment.theme) # remove this

    images_path = Dir.glob(File.join(theme.filesystem_path, 'images', block.preview_path, '*'))
    images_path = images_path.map{|path| path.gsub(theme.filesystem_path, theme.public_path) } unless images_path.empty?

    images_path = Dir.glob(File.join(Rails.root, 'public', plugin.public_path, 'images', block.preview_path, '*')) if plugin && images_path.empty?
    images_path = images_path.map{|path| path.gsub(File.join(Rails.root, 'public'), '') } unless images_path.empty?

    images_path = Dir.glob(File.join(Rails.root, 'public', 'images', block.preview_path, '*')) if images_path.empty?
    images_path = images_path.map{|path| path.gsub(File.join(Rails.root, 'public'), '') } unless images_path.empty?

    images_path = 1.upto(3).map{block.default_preview_path} if images_path.empty?

    content_tag(:ul,
      images_path.map do |preview|
	content_tag(:li, image_tag(preview, height: '240', alt: ''))
      end.join("\n")
    )
  end

  def icon_selector(icon = 'no-ico')
    render :partial => 'icon_selector', :locals => { :icon => icon }
  end

  def extra_option_checkbox(option)
    if [:human_name, :name, :value, :checked, :options].all? {|k| option.key? k}
      labelled_check_box(option[:human_name], option[:name], option[:value], option[:checked], option[:options])
    end
  end

end
