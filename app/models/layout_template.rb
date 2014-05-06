class LayoutTemplate

  def self.find(id)
    t = new(id)
    t.send(:read_config)
    t
  end

  def self.all
    Dir.glob(Rails.root.join('public', 'designs', 'templates', '*')).map {|item| find(File.basename(item)) }
  end

  attr_reader :id
  def initialize(id)
    @id = id
  end

  def name
    _ @config['name']
  end

  def title
    _ @config['title']
  end

  def description
    _ @config['description']
  end

  def number_of_boxes
    @config['number_of_boxes']
  end

  protected

  def read_config
    @config = YAML.load_file(Rails.root.join('public', 'designs', 'templates', id, 'config.yml'))
  end

end
