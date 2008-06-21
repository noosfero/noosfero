module Noosfero
  PROJECT = 'noosfero'
  VERSION = '0.10.1'
  SVN_ROOT = 'https://svn.colivre.coop.br/svn/noosfero'

  def self.pattern_for_controllers_in_directory(dir)
    disjunction = controllers_in_directory(dir).join('|')
    pattern = disjunction.blank? ? '' : ('(' + disjunction + ')')
    Regexp.new(pattern)
  end

  class << self
    attr_accessor :locales
    attr_accessor :default_locale
    def available_locales
      Dir.glob(File.join(RAILS_ROOT, 'locale', '*')).map { |f| File.basename(f) }
    end
  end

  def self.identifier_format
    '[a-z][a-z0-9~.]*([_-][a-z0-9~.]+)*'
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
