class LayoutTemplate

  def self.find(id)
    t = new(id)
    t.send(:read_config)
    t
  end

  def self.all
    Dir.glob(File.join(RAILS_ROOT, 'public', 'designs', 'templates', '*')).map {|item| find(File.basename(item)) }
  end

  attr_reader :id
  def initialize(id)
    @id = id
  end

  def title
    @config['title']
  end

  def description
    @config['description']
  end

  def number_of_boxes
    @config['number_of_boxes']
  end

  protected

  def read_config
    @config = YAML.load_file(File.join(RAILS_ROOT, 'public', 'designs', 'templates', id, 'config.yml'))
  end

end
