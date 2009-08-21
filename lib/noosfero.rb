module Noosfero
  PROJECT = 'noosfero'
  VERSION = '0.19.3'
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
      @available_locales ||= (Dir.glob(File.join(RAILS_ROOT, 'locale', '*')).map { |f| File.basename(f) }.select {|item| locales.include?(item) })
    end
    def each_locale
      locales.keys.sort.each do |key|
        yield(key, locales[key])
      end
    end
  end

  def self.identifier_format
    '[a-z0-9][a-z0-9~.]*([_-][a-z0-9~.]+)*'
  end

  private

  def self.controllers_in_directory(dir)
    app_controller_path = Dir.glob(File.join(RAILS_ROOT, 'app', 'controllers', dir, '*_controller.rb'))
    app_controller_path.map do |item|
      item.gsub(/^.*\/([^\/]+)_controller.rb$/, '\1')
    end
  end

  def self.term(t)
    self.terminology.get(t)
  end
  def self.terminology
    @terminology ||= Noosfero::Terminology::Default.instance
  end
  def self.terminology=(term)
    @terminology = term
  end

  def self.url_options
    if ENV['RAILS_ENV'] == 'development'
      development_url_options
    else
      {}
    end
  end

  # FIXME couldn't think of a way to test this.
  #
  # Works (tested by hand) on Rails 2.0.2, with mongrel. Should work with
  # webrick too.
  def self.development_url_options
    if Object.const_defined?('OPTIONS')
      { :port => OPTIONS[:port ]}
    else
      {}
    end
  end


end

require 'noosfero/constants'
require 'noosfero/core_ext'
