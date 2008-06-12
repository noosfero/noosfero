require File.dirname(__FILE__) + '/../config/environment'

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

  def new_cat(name, parent = nil)
    path = (parent ? parent.path + '/' : '') + name.to_slug
    pc = ProductCategory.find_by_path(path) || ProductCategory.create!(:name => name, :parent => parent, :environment => Environment.default)
    print '.'
    pc
  end

  def new_region(name, parent, lat, lng)
    path = (parent ? parent.path + '/' : '') + name.to_slug
    region = Region.find_by_path(path) || Region.create!(:name => name, :parent => parent, :lat => lat, :lng => lng, :environment => Environment.default)
    print '.'
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
    ent = Enterprise.create!({:environment => Environment.default}.merge(data), :enabled => false)
    products.each do |p|
      ent.products.create!(p) unless ent.products.find(:first, :conditions => p)
    end
    consumptions.each do |c|
      ent.consumptions.create!(c) unless ent.consumptions.find(:first, :conditions => c)
    end
    print '.'
  end
