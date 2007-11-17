module Noosfero
  PROJECT = 'noosfero'
  VERSION = '0.4.0'
  SVN_ROOT = 'https://svn.colivre.coop.br/svn/noosfero'

  def self.pattern_for_controllers_in_directory(dir)
    disjunction = controllers_in_directory(dir).join('|')
    pattern = disjunction.blank? ? '' : ('(' + disjunction + ')')
    Regexp.new(pattern)
  end

#  FIXME This path is not working. I put a line deteach on the 'controllers_in_directory' method to meka the blocks
#  works
#  def self.pattern_for_controllers_from_design_blocks
#    items = Dir.glob(File.join(RAILS_ROOT, 'app', 'design_blocks', '*', 'controllers', '*_controller.rb')).map do |item|
#      item.gsub(/^.*\/([^\/]+)_controller.rb$/, '\1')
#    end.join('|')
#    Regexp.new(items.blank? ? '' : ('(' + items + ')'))
#  end

  private

  def self.controllers_in_directory(dir)
    app_controller_path = Dir.glob(File.join(RAILS_ROOT, 'app', 'controllers', dir, '*_controller.rb'))
    items = Dir.glob(File.join(RAILS_ROOT, 'app', 'design_blocks', '*', 'controllers', '*_controller.rb')) # FIXME line added to blocks works
    (app_controller_path + items).map do |item|
      item.gsub(/^.*\/([^\/]+)_controller.rb$/, '\1')
    end
  end

end

require 'noosfero/constants'
