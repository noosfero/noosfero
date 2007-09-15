module Noosfero
  PROJECT = 'noosfero'
  VERSION = '0.2.0~alpha'
  SVN_ROOT = 'https://svn.colivre.coop.br/svn/noosfero'

  def self.controllers_in_directory(dir)
    Dir.glob(File.join(RAILS_ROOT, 'app', 'controllers', dir, '*_controller.rb')).map do |item|
      item.gsub(/^.*\/([^\/]+)_controller.rb$/, '\1')
    end
  end

  def self.pattern_for_controllers_in_directory(dir)
    disjunction = controllers_in_directory(dir).join('|')
    pattern = disjunction.blank? ? '' : (('(' + disjunction + ')'))
    Regexp.new(pattern)
  end
end
