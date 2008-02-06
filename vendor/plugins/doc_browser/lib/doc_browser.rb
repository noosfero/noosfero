# doc_browser - a documentation browser plugin for Rails
# Copyright (C) 2007 Colivre <http://www.colivre.coop.br>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Searches for documentation installed in a Rails application.
module DocBrowser

  # searches for documentation installed in a Rails application. Returns an
  # Array of Hashes with the found docs. Each entry of the array looks like
  # this:
  #  {
  #   :name => 'name',
  #   :title => 'Some descriptive title',
  #   :link => 'doc/name/index.html',
  #   :doc_exists => true, # in the case the documentation is installed,
  #   :dont_exist_message => 'some message' # to be displayed if the doc is not installed
  #  }
  def self.find_docs(root = RAILS_ROOT)
    docs = []

    # API documentation
    docs << {
      :name => 'api',
      :title => 'Rails API documentation',
      :link => "/doc/api/index.html",
      :doc_exists => File.exists?(File.join(root, 'doc', 'api')),
      :dont_exist_message => 'not present. Run <tt>rake doc:rails</tt> to generate documentation for the Rails API.',
    }

    # Application documentation
    docs << {
      :name => 'app',
      :title => 'Application documentation',
      :link => "/doc/app/index.html",
      :doc_exists => File.exists?(File.join(root, 'doc', 'app')),
      :dont_exist_message => 'not present. Run <tt>rake doc:app</tt> to generate documentation for your application.',
    }

    Dir.glob(File.join(root, 'vendor', 'plugins', '*')).select do |f|
      File.directory?(f)
    end.map do |dir|
      name = File.basename(dir)
      { 
        :name => name,
        :title => "#{name} plugin",
        :link => ("/doc/plugins/#{name}/index.html"),
        :doc_exists => File.exists?(File.join(root, 'doc', 'plugins', name)),
        :dont_exist_message => 'Documentation not generated. Run <tt>rake doc:plugins</tt> to generate documentation for all plugins in your application.',
      }
    end.each do |item|
      docs << item
    end

    docs
  end

  # checks if there are any errors that may prevent the user to see any
  # documentation. Returns an Array with error messages.
  #
  # An empty Array, of course, means no errors.
  def self.errors(root = RAILS_ROOT)
    errors = []

    unless File.exists?(File.join(root, 'public', 'doc'))
      errors << "There is no symbolic link to your doc directory inside your public directory. Documentation links are probably going to be broken (or even point to parts of your application). To fix this, enter your public/ directory and do <tt>ln -s ../doc</tt>"
    end
    errors
  end

end

