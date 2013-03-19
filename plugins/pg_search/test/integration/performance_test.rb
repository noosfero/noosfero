require 'test_helper'
require 'benchmark'

class PerformanceTest < ActionController::IntegrationTest

  searchables = %w[ article comment qualifier national_region certifier profile license scrap category ]
  quantities = [10, 100, 1000]

  searchables.each do |searchable|
    self.send(:define_method, "test_#{searchable}_performance") do
      klass = searchable.camelize.constantize
      asset = searchable.pluralize.to_sym
      quantities.each do |quantity|
        create(klass, quantity)
        get 'index'
        like = Benchmark.measure { 10.times { @controller.send(:find_by_contents, asset, klass, searchable) } }
        puts "Like for #{quantity}: #{like}"
        Environment.default.enable_plugin(PgSearchPlugin)
        get 'index'
        like = Benchmark.measure { 10.times { @controller.send(:find_by_contents, asset, klass, searchable) } }
        puts "Pg for #{quantity}: #{pg}"
      end
    end
  end

  private

  def create(klass, quantity)
    klass.destroy_all
    quantity.times.each {fast_create(klass)}
  end
end
