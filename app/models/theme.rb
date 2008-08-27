class Theme

  class << self
    def system_themes
      Dir.glob(RAILS_ROOT + '/public/designs/themes/*').map do |item|
        File.basename(item)
      end.map do |item|
        new(item)
      end
    end

    def user_themes_dir
      File.join(RAILS_ROOT, 'public', 'user_themes')
    end

    def create(id, attributes = {})
      if find(id) || system_themes.map(&:id).include?(id)
        raise DuplicatedIdentifier
      end
      Theme.new(id, attributes).save
    end

    def find(the_id)
      if File.directory?(File.join(user_themes_dir, the_id))
        Theme.new(the_id)
      else
        nil
      end
    end

    def find_by_owner(owner)
      Dir.glob(File.join(user_themes_dir, '*', 'theme.yml')).select do |desc|
        config = YAML.load_file(desc)
        (config['owner_type'] == owner.class.base_class.name) && (config['owner_id'] == owner.id)
      end.map do |desc|
        Theme.find(File.basename(File.dirname(desc)))
      end
    end

  end

  class DuplicatedIdentifier < Exception; end

  attr_reader :id
  attr_reader :config

  def initialize(id, attributes = {})
    @id = id
    load_config
    attributes.each do |k,v|
      self.send("#{k}=", v)
    end
  end

  def name
    config['name'] || id
  end

  def name=(value)
    config['name'] = value
  end

  def ==(other)
    other.is_a?(self.class) && (other.id == self.id)
  end

  def add_css(filename)
    FileUtils.mkdir_p(stylesheets_directory)
    FileUtils.touch(stylesheet_path(filename))
  end

  def update_css(filename, content)
    add_css(filename)
    File.open(stylesheet_path(filename), 'w') do |f|
      f.write(content)
    end
  end

  def read_css(filename)
    File.read(stylesheet_path(filename))
  end

  def css_files
    Dir.glob(File.join(stylesheets_directory, '*.css')).map { |f| File.basename(f) }
  end

  def add_image(filename, data)
    FileUtils.mkdir_p(images_directory)
    File.open(image_path(filename), 'w') do |f|
      f.write(data)
    end
  end

  def image_files
    Dir.glob(image_path('*')).map {|item| File.basename(item)}
  end

  def stylesheet_path(filename)
    suffix = ''
    unless filename =~ /\.css$/
      suffix = '.css'
    end
    File.join(stylesheets_directory, filename + suffix)
  end

  def stylesheets_directory
    File.join(Theme.user_themes_dir, self.id, 'stylesheets')
  end

  def image_path(filename)
    File.join(images_directory, filename)
  end

  def images_directory
    File.join(self.class.user_themes_dir, id, 'images')
  end

  def save
    FileUtils.mkdir_p(self.class.user_themes_dir)
    FileUtils.mkdir_p(File.join(self.class.user_themes_dir, id))
    %w[ common help menu article button search blocks forms login-box ].each do |item|
      add_css(item)
    end
    write_config
    self
  end

  def owner
    return nil unless config['owner_type'] && config['owner_id']
    @owner ||= config['owner_type'].constantize.find(config['owner_id'])
  end

  def owner=(model)
    config['owner_type'] = model.class.base_class.name
    config['owner_id'] = model.id
    @owner = model
  end

  protected

  def write_config
    File.open(File.join(self.class.user_themes_dir, self.id, 'theme.yml'), 'w') do |f|
      f.write(config.to_yaml)
    end
  end

  def load_config
    if File.exists?(File.join(self.class.user_themes_dir, self.id, 'theme.yml'))
      @config = YAML.load_file(File.join(self.class.user_themes_dir, self.id, 'theme.yml'))
    else
      @config = {}
    end
  end

end
