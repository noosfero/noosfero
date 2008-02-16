module Noosfero
  PROJECT = 'noosfero'
  VERSION = '0.7.0'
  SVN_ROOT = 'https://svn.colivre.coop.br/svn/noosfero'

  def self.pattern_for_controllers_in_directory(dir)
    disjunction = controllers_in_directory(dir).join('|')
    pattern = disjunction.blank? ? '' : ('(' + disjunction + ')')
    Regexp.new(pattern)
  end

  def self.pattern_for_controllers_from_design_blocks
    items = Dir.glob(File.join(RAILS_ROOT, 'app', 'design_blocks', '*', 'controllers', '*_controller.rb')).map do |item|
      item.gsub(/^.*\/([^\/]+)_controller.rb$/, '\1')
    end.join('|')
    Regexp.new(items.blank? ? '' : ('(' + items + ')'))
  end

  class << self
    attr_accessor :locales
  end

  private

  def self.controllers_in_directory(dir)
    app_controller_path = Dir.glob(File.join(RAILS_ROOT, 'app', 'controllers', dir, '*_controller.rb'))
    app_controller_path.map do |item|
      item.gsub(/^.*\/([^\/]+)_controller.rb$/, '\1')
    end
  end

end

require 'noosfero/constants'
require 'noosfero/core_ext'
