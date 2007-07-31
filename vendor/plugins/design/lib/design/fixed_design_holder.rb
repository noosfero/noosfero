module Design

  class FixedDesignHolder
    attr_reader :template, :theme, :icon_theme, :boxes
    def initialize(options = {})
      @template = options[:template] || 'default'
      @theme = options[:theme] || 'default'
      @icon_theme = options[:icon_theme] || 'default'
      @boxes = options[:boxes] || default_boxes
    end
  
    # creates some default boxes
    def default_boxes
      box1 = Box.new
      box2 = Box.new
      box2.blocks << MainBlock.new
      box3 = Box.new
  
      [box1, box2, box3]
    end
    private :default_boxes
  end

end

