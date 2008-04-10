#!/usr/bin/ruby

$LOAD_PATH.unshift('/usr/share/rails/activerecord/lib')
$LOAD_PATH.unshift('/usr/share/rails/activesupport/lib')

require 'activerecord'
require 'active_support'

LIMIT = 5

# To connect with the database that contains the data to be extracted cofigure it in the 'database_farejador.yml' with the name 'farejador'
ActiveRecord::Base.establish_connection(YAML::load(IO.read('database_farejador.yml'))['farejador'])

class Enterprise < ActiveRecord::Base
  set_table_name 'cons_dadosbasicos'
end

class Category < ActiveRecord::Base
  set_table_name 'lista_produtos'
end

class Dumper
  def initialize
    @seq = 0
    @seqs = {}
  end

  def pretty(str, alt = nil)
    if alt.nil?
      str
    else
      str + ' (' + alt + ')'
    end
  end

  def dump(cat, parent = nil)

    @seqs[cat] = @seq
    puts "cat#{@seq} = Category.create!(:name => #{pretty(cat.nome, cat.nome_alt).inspect}, :parent => #{parent ? 'cat' + @seqs[parent].to_s : 'nil' })"
    @seq = @seq + 1

    Category.find(:all, :conditions => { :id_mae => cat.id }).each do |child|
      dump(child, cat)
    end

  end

end

dumper = Dumper.new
Category.find(:all, :conditions => 'id_mae is null or id_mae = -1').each do |cat|
  dumper.dump(cat, nil)
end

# puts Enterprise.find(:all, :limit => LIMIT).to_xml
