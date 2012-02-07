require "test_helper"
class NativeMetricTest < ActiveSupport::TestCase

  def self.total_cof
    total_cof = Kalibro::Entities::NativeMetric.new
    total_cof.name = 'Total Coupling Factor'
    total_cof.scope = 'APPLICATION'
    total_cof.origin = 'Analizo'
    total_cof.language = 'JAVA'
    total_cof
  end

  def self.amloc
    total_cof = Kalibro::Entities::NativeMetric.new
    total_cof.name = 'Average Method LOC'
    total_cof.scope = 'CLASS'
    total_cof.origin = 'Analizo'
    total_cof.language = 'JAVA'
    total_cof
  end

  def self.total_cof_hash
    {:name => 'Total Coupling Factor', :scope => 'APPLICATION',
      :origin => 'Analizo', :language => 'JAVA'}
  end

  def self.amloc_hash
    {:name => 'Average Method LOC', :scope => 'CLASS',
      :origin => 'Analizo', :language => 'JAVA'}
  end
  
  def setup
    @hash = self.class.amloc_hash
    @metric = self.class.amloc
  end

  should 'create native metric from hash' do
    assert_equal @metric, Kalibro::Entities::NativeMetric.from_hash(@hash)
  end

  should 'convert native metric to hash' do
    assert_equal @hash, @metric.to_hash
  end

end