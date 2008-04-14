#!/usr/bin/ruby

$LOAD_PATH.unshift('/usr/share/rails/activerecord/lib')
$LOAD_PATH.unshift('/usr/share/rails/activesupport/lib')

require 'activerecord'
require 'active_support'
require File.dirname(__FILE__) + "/../" + 'lib/noosfero/core_ext/string.rb'

LIMIT = (ENV['DUMP_ALL'] ? nil : 5)
DUMP_ALL = LIMIT.nil?

# To connect with the database that contains the data to be extracted cofigure it in the 'database_farejador.yml' with the name 'farejador'
ActiveRecord::Base.establish_connection(YAML::load(IO.read(File.dirname(__FILE__) + '/database_farejador.yml'))['farejador'])

class Enterprise < ActiveRecord::Base
  set_table_name 'cons_dadosbasicos'
  set_primary_key :id_sies
  has_many :products, :foreign_key => 'V00', :conditions => "tipo = 'produto'"
  has_many :input_products, :class_name => 'Product', :foreign_key => 'V00', :conditions => "tipo = 'insumo'"
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
cat#{@seq} = ProductCategory.create!(:name => #{pretty(cat.nome, cat.nome_alt).inspect}, :parent => #{parent ? 'cat' + @seqs[parent].to_s : 'nil' })
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
enterprise = Enterprise.create!(
  :name => #{ent.nome.inspect},
  :identifier => #{ent.nome.to_slug.inspect},
  :contact_phone => #{ent.tel.inspect},
  :address => #{endereco.inspect},
  :lat => #{ent.lat.inspect},
  :lng => #{ent.long.inspect},
  :geocode_precision => #{ent.geomodificou.inspect},
  :data => {
    :id_sies => #{ent.id_sies.inspect}
  },
  :organization_info => OrganizationInfo.new(
    :contact_email => #{email.inspect}
  )
)
    EOF

    ent.products.each do |p|
      cat = p.category
      puts <<-EOF
enterprise.products.create!(
  :name => #{cat.nome.inspect},
  :product_category_id => categories[#{cat.id}]
)
      EOF
    end

    ent.input_products.each do |i|
      cat = i.category
      puts <<-EOF
enterprise.consumptions.create!(
  :product_category_id => categories[#{cat.id}]
)
      EOF
    end

  end

  def dump_city(city)
    puts <<-EOF
Region.create!(
  :name => #{city.cidade.inspect},
  :parent => STATES[#{city.id.to_s[0..1]}],
  :lat => #{city.latitude},
  :lng => #{city.longitude}
)
    EOF
  end

end

dumper = Dumper.new

puts "categories = {}"
Category.find(:all, :conditions => 'id_mae is null or id_mae = -1', :limit => LIMIT).each do |cat|
  dumper.dump_category(cat, nil)
end

Enterprise.find(:all, :limit => LIMIT).each do |ent|
  dumper.dump_enterprise(ent)
end

puts <<-EOF
STATES = {
  12 => Region.find_by_name('Acre'),
  27 => Region.find_by_name('Alagoas'),
  13 => Region.find_by_name('Amazonas'),
  16 => Region.find_by_name('Amapá'),
  29 => Region.find_by_name('Bahia'),
  23 => Region.find_by_name('Ceará'),
  53 => Region.find_by_name('Distrito Federal'),
  32 => Region.find_by_name('Espírito Santo'),
  52 => Region.find_by_name('Goiás'),
  21 => Region.find_by_name('Maranhão'),
  31 => Region.find_by_name('Minas Gerais'),
  50 => Region.find_by_name('Mato Grosso do Sul'),
  51 => Region.find_by_name('Mato Grosso'),
  15 => Region.find_by_name('Pará'),
  25 => Region.find_by_name('Paraíba'),
  26 => Region.find_by_name('Pernambuco'),
  22 => Region.find_by_name('Piauí'),
  41 => Region.find_by_name('Paraná'),
  33 => Region.find_by_name('Rio de Janeiro'),
  24 => Region.find_by_name('Rio Grande do Norte'),
  11 => Region.find_by_name('Rondônia'),
  14 => Region.find_by_name('Roraima'),
  43 => Region.find_by_name('Rio Grande do Sul'),
  42 => Region.find_by_name('Santa Catarina'),
  28 => Region.find_by_name('Sergipe'),
  35 => Region.find_by_name('São Paulo'),
  17 => Region.find_by_name('Tocantins'),
}
EOF

City.find(:all, :limit => LIMIT).each do |city|
  dumper.dump_city(city)
end
