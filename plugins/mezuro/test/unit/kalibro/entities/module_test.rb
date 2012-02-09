require "test_helper"
class ModuleTest < ActiveSupport::TestCase

  def self.qt_calculator
    entity = Kalibro::Entities::Module.new
    entity.name = ProjectTest.qt_calculator.name
    entity.granularity = 'APPLICATION'
    entity
  end

  def self.qt_calculator_hash
    name = ProjectTest.qt_calculator.name
    {:name => name, :granularity => 'APPLICATION'}
  end

  def setup
    @hash = self.class.qt_calculator_hash
    @module = self.class.qt_calculator
  end

  should 'create module from hash' do
    assert_equal @module, Kalibro::Entities::Module.from_hash(@hash)
  end
  
  should 'convert module to hash' do
    assert_equal @hash, @module.to_hash
  end

end