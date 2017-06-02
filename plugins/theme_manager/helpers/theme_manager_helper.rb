module ThemeManagerHelper

  def unzip_file (file, destination)
    Open3.popen3({'LANG'=>'C.UTF-8'}, 'unzip', file, '-d', destination) do |stdin, stdout, stderr, io|
      stderr = stderr.read
      success = io.value.success?
      return success, stderr
    end
  end

  def validate_theme_files(theme_dir)
    begin
      conf = YAML::load File.read(File.join(theme_dir, 'theme.yml'))
      if conf.empty?
        return {error: _('theme.yml is empty.')}
      end
      unless conf['name']
        return {error: _('theme.yml has no name.')}
      end
    rescue Exception => err
      return {error: err.message}
    end
    return {name: conf['name']}
  end

  def find_theme_root(base_dir)
    path = `find #{base_dir} -name theme.yml`.split("\n").first
    if path.empty?
      base_dir
    else
      path[0..-11] # extract 'theme.yml' from path
    end
  end

  def activate_theme(theme_dir, theme_name, env)
    begin
      FileUtils.cp_r theme_dir, 'public/designs/themes/'+theme_name.to_slug
      env.add_themes [theme_name.to_slug]
      env.save!
      return true, nil
    rescue Exception => err
      return false, err
    end
  end

  def get_theme_package(temp, pack)
    zip = File.join temp, 'package.zip'
    File.open(zip, "wb") do |f|
      f.write pack.read
    end
    file_type = `file -b --mime-type #{zip}`.strip
    return { zip: zip, file_type: file_type }
  end

  def list_enabled_themes
    visible_themes = environment.themes.map &:id
    instaled_dir = File.join Rails.root, '/public/designs/themes/'
    enabled_themes =
    Dir.glob(instaled_dir+'/*')
    .map{|d| d.split('/').last}
    .select {|d| d != 'disabled_themes'}
    .inject({}) do |memo, theme|
      conf = YAML::load File.read File.join( instaled_dir, theme , 'theme.yml' )
      memo[theme] = {visible: visible_themes.include?(theme), name:conf['name']}
      memo
    end
  end

  def list_disabled_themes
    disabled_dir = File.join Rails.root, '/public/designs/themes/disabled_themes'
    disabled_themes = (Dir.exists? (disabled_dir)) ? Dir.glob(disabled_dir+'/*')
    .map{|d| d.split('/').last}
    .select {|d| d != '.' && d != '..'} : []
  end

end
