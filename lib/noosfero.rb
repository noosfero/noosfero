module Noosfero
  PROJECT = 'noosfero'
  VERSION = '0.3.0'
  SVN_ROOT = 'https://svn.colivre.coop.br/svn/noosfero'

  def self.controllers_in_directory(dir)
    app_controller_path = Dir.glob(File.join(RAILS_ROOT, 'app', 'controllers', dir, '*_controller.rb'))

    # FIXME we can remove this line here if the controllers needed by application are not loaded 
    # directly
    design_controller_path = Dir.glob(File.join(RAILS_ROOT, 'app', 'design_blocks', '*', 'controllers', '*_controller.rb'))

    (app_controller_path + design_controller_path).map do |item|
      item.gsub(/^.*\/([^\/]+)_controller.rb$/, '\1')
    end
  end

  def self.pattern_for_controllers_in_directory(dir)
    disjunction = controllers_in_directory(dir).join('|')
    pattern = disjunction.blank? ? '' : (('(' + disjunction + ')'))
    Regexp.new(pattern)
  end
end

require 'noosfero/constants'
