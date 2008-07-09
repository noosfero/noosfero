require File.dirname(__FILE__) + '/../config/environment'
require 'console_with_helpers'

STATES = {
  12 => State.find_by_name('Acre'),
  27 => State.find_by_name('Alagoas'),
  13 => State.find_by_name('Amazonas'),
  16 => State.find_by_name('Amapá'),
  29 => State.find_by_name('Bahia'),
  23 => State.find_by_name('Ceará'),
  53 => State.find_by_name('Distrito Federal'),
  32 => State.find_by_name('Espírito Santo'),
  52 => State.find_by_name('Goiás'),
  21 => State.find_by_name('Maranhão'),
  31 => State.find_by_name('Minas Gerais'),
  50 => State.find_by_name('Mato Grosso do Sul'),
  51 => State.find_by_name('Mato Grosso'),
  15 => State.find_by_name('Pará'),
  25 => State.find_by_name('Paraíba'),
  26 => State.find_by_name('Pernambuco'),
  22 => State.find_by_name('Piauí'),
  41 => State.find_by_name('Paraná'),
  33 => State.find_by_name('Rio de Janeiro'),
  24 => State.find_by_name('Rio Grande do Norte'),
  11 => State.find_by_name('Rondônia'),
  14 => State.find_by_name('Roraima'),
  43 => State.find_by_name('Rio Grande do Sul'),
  42 => State.find_by_name('Santa Catarina'),
  28 => State.find_by_name('Sergipe'),
  35 => State.find_by_name('São Paulo'),
  17 => State.find_by_name('Tocantins'),
}

COUNT = {
  :enterprises => 0,
  :regions => 0,
  :categories => 0,
}

$default_env = Environment.default
def step(what)
  COUNT[what] += 1
  puts "#{what}: #{COUNT[what]}"
end

  def new_cat(name, parent = nil)
    path = (parent ? parent.path + '/' : '') + name.to_slug
    pc = Category.find_by_path(path) 
    pc = ProductCategory.create!(:name => name, :parent => parent, :environment => $default_env) unless pc
    step(:categories)
    pc
  end

  def new_region(name, parent, lat, lng)
    path = (parent ? parent.path + '/' : '') + name.to_slug
    region = City.find_by_path(path) 
    region = City.create!(:name => name, :parent => parent, :lat => lat, :lng => lng, :environment => $default_env) unless region
    step(:regions)
    region
  end

  def new_ent(data, products, consumptions)
    count = 2
    ident = data[:identifier]
    idents = Enterprise.find(:all, :conditions => ['identifier like ?', ident + '%']).map(&:identifier)
    while idents.include?(ident)
      ident = data[:identifier] + "-#{count}"
      count += 1
    end
    data[:identifier] = ident
    ent = Enterprise.create!({:environment => $default_env, :enabled => false}.merge(data))
    products.each do |p|
      ent.products.create(p)
    end
    consumptions.each do |c|
      ent.consumptions.create(c)
    end
    step(:enterprises)
  end
