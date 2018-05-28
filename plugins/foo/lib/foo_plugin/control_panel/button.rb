class FooPlugin::Button < ControlPanel::Entry
  class << self
    def name
      'Foo plugin button'
    end

    def section
      'others'
    end
  end
end
