#!/usr/bin/ruby

$LOAD_PATH.unshift('/usr/share/rails/activerecord/lib')
$LOAD_PATH.unshift('/usr/share/rails/activesupport/lib')

require 'activerecord'
require 'active_support'
require File.dirname(__FILE__) + "/../" + 'lib/noosfero/core_ext/string.rb'


LIMIT = (ENV['DUMP_ALL'] ? nil : 10)
DUMP_ALL = LIMIT.nil?

# To connect with the database that contains the data to be extracted cofigure it in the 'database_farejador.yml' with the name 'farejador'
ActiveRecord::Base.establish_connection(YAML::load(IO.read(File.dirname(__FILE__) + '/database_farejador.yml'))['farejador'])

class Enterprise < ActiveRecord::Base
  set_table_name 'cons_dadosbasicos'
  set_primary_key :id_sies
  has_many :products, :foreign_key => 'V00', :conditions => "tipo = 'produto'"
  has_many :input_products, :class_name => 'Product', :foreign_key => 'V00', :conditions => "tipo = 'insumo'"
  has_one :extra_data, :foreign_key => 'V00'
end

class ExtraData < ActiveRecord::Base
  set_table_name 'dados_extra'
end

class Product < ActiveRecord::Base
  set_table_name 'mapa_produtos'
  belongs_to :category, :foreign_key => 'id_prod'
end

class Category < ActiveRecord::Base
  set_table_name 'lista_produtos'
end

class Macroregion < ActiveRecord::Base
  set_table_name 'macrorregioes'
end

class State < ActiveRecord::Base
  set_table_name 'estados'
  set_primary_key :id_UF
  has_one :macroregion, :foreign_key => 'UF'

  def cities
    City.find(:all, :conditions => [ "id < 6000000 and id like '?%'", id_UF])
  end
end

class City < ActiveRecord::Base
  set_table_name 'cidades_ibge'
end

class Dumper
  def initialize
    @seq = 0
    @seqs = {}
    @r_seq = 0
    @r_seqs = {}
  end

  def pretty(str, alt = nil)
    if alt.nil?
      str
    else
      str + ' (' + alt + ')'
    end
  end

  def dump_category(cat, parent = nil)
    
    @seqs[cat] = @seq
    puts <<-EOF
cat#{@seq} = new_cat(#{pretty(cat.nome, cat.nome_alt).inspect}, #{parent ? 'cat' + @seqs[parent].to_s : 'nil' })
categories[#{cat.id}] = cat#{@seq}.id
    EOF
    @seq += 1

    Category.find(:all, :conditions => { :id_mae => cat.id }).each do |child|
      dump_category(child, cat) if (DUMP_ALL || (@seq <= LIMIT))
    end

  end

  def dump_enterprise(ent)
    email = nil
    contato = nil
    if (ent.corel =~ /@/)
      email = ent.corel
    else
      contato = ent.corel
    end

    endereco = ent.end
    if ent.cep
      endereco << " CEP: " << ent.cep
    end

    puts <<-EOF
new_ent({ :name => #{ent.nome.inspect}, 
          :identifier => #{ent.nome.to_slug.inspect}, 
          :contact_phone => #{ent.tel.inspect}, 
          :address => #{endereco.inspect}, 
          :lat => #{ent.lat.inspect}, 
          :lng => #{ent.long.inspect}, 
          :geocode_precision => #{ent.geomodificou.inspect}, 
          :data => { 
            :id_sies => #{ent.id_sies.inspect}
           }, 
          :contact_email => #{email.inspect},
          :foundation_year => #{ent.extra_data.ANO.inspect},
          :cnpj => #{ent.extra_data.CNPJ.inspect},
          :category_ids => [cities[#{ent.id_cidade}]].map(&:id)
        },
      [#{ent.products.map{|p| "{ :name => #{p.category.nome.inspect} , :product_category_id => categories[#{p.category.id}] }"}.join(', ')}], 
      [#{ent.input_products.map{|p| "{ :product_category_id => categories[#{p.category.id}]}" }.join(', ')}])
EOF
  end

  def dump_city(city)
    @r_seqs[city] = @r_seq
    puts <<-EOF
city#{@r_seq} = new_region(#{city.cidade.inspect}, STATES[#{city.id.to_s[0..1]}], #{city.latitude}, #{city.longitude})
cities[#{city.id}] = city#{@r_seq}
    EOF
    @r_seq += 1
  end

end

dumper = Dumper.new

puts <<-EOF
#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'
require File.dirname(__FILE__) + '/fbes_populate_helper.rb'

GetText.locale = 'pt_BR'

EOF

puts "categories = {}"
Category.find(:all, :conditions => 'id_mae is null or id_mae = -1', :limit => LIMIT).each do |cat|
  dumper.dump_category(cat, nil)
end

puts "cities = {}"
City.find(:all, :limit => LIMIT).each do |city|
  dumper.dump_city(city)
end

Enterprise.find(:all, :limit => LIMIT).each do |ent|
  dumper.dump_enterprise(ent)
end
