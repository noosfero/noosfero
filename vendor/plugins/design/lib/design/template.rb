module Design
  class Template

    def initialize(name, data)
      @data = data
      @data['name'] = name
    end
    def self.find(name)
      directory = File.join(Design.public_filesystem_root, Design.design_root, 'templates', name)
      yaml_files = Dir.glob(File.join(directory, '*.yml'))

      if yaml_files.size != 1
        raise "#{name} is not a valid template. There must be one (and only one) YAML (*.yml) file describing it in #{directory})"
      end

      data = YAML.load_file(yaml_files.first)

      self.new(name, data)
    end
    def name
      @data['name']
    end
    def title
      @data['title'] || name
    end
    def number_of_boxes
      @data['number_of_boxes'] || 3
    end
  end
end
