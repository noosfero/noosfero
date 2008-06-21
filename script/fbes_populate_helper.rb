require File.dirname(__FILE__) + '/../config/environment'

STATES = {}

[ 'Acre',
  'Alagoas',
  'Amazonas',
  'Amapá',
  'Bahia',
  'Ceará',
  'Distrito Federal',
  'Espírito Santo',
  'Goiás',
  'Maranhão',
  'Minas Gerais',
  'Mato Grosso do Sul',
  'Mato Grosso',
  'Pará',
  'Paraíba',
  'Pernambuco',
  'Piauí',
  'Paraná',
  'Rio de Janeiro',
  'Rio Grande do Norte',
  'Rondônia',
  'Roraima',
  'Rio Grande do Sul',
  'Santa Catarina',
  'Sergipe',
  'São Paulo',
  'Tocantins'
].each do |statename|
  st = Region.find_by_name(statename)
  STATES[st.id] = st
end

COUNT = {
  :enterprises => 0,
  :regions => 0,
  :categories => 0,
}

def step(what)
  COUNT[what] += 1
  puts "#{what}: #{COUNT[what]}"
end

  def new_cat(name, parent = nil)
    path = (parent ? parent.path + '/' : '') + name.to_slug
    pc = Category.find_by_path(path) 
    pc = ProductCategory.create!(:name => name, :parent => parent, :environment => Environment.default) unless pc
    step(:categories)
    pc
  end

  def new_region(name, parent, lat, lng)
    path = (parent ? parent.path + '/' : '') + name.to_slug
    region = Region.find_by_path(path) 
    region = Region.create!(:name => name, :parent => parent, :lat => lat, :lng => lng, :environment => Environment.default) unless region
    step(:regions)
    region
  end

  def new_ent(data, products, consumptions)
    count = 2
    ident = data[:identifier]
    while Enterprise.find_by_identifier(ident)
      ident = data[:identifier] + "-#{count}"
      count += 1
    end
    data[:identifier] = ident
    ent = Enterprise.create!({:environment => Environment.default, :enabled => false}.merge(data))
    products.each do |p|
      ent.products.create(p)
    end
    consumptions.each do |c|
      ent.consumptions.create(c)
    end
    step(:enterprises)
  end
