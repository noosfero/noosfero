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
    ProductCategory.find_by_path(path) || ProductCategory.create!(:name => name, :parent => parent, :environment => Environment.default)
  end

  def new_region(name, parent, lat, lng)
    path = (parent ? parent.path + '/' : '') + name.to_slug
    Region.find_by_path(path) || Region.create!(:name => name, :parent => parent, :lat => lat, :lng => lng, :environment => Environment.default)
  end

  def new_ent(data, products, consumptions)
    posfix = ''
    count = 1
    while Enterprise.find_by_identifier(data[:identifier] = (data[:identifier] + posfix)) do
      count += 1
      posfix = "-#{count}"
    end
    ent = Enterprise.create!({:environment => Environment.default}.merge(data))
    products.each do |p|
      ent.products.create!(p)
    end
    consumptions.each do |c|
      ent.consumptions.create!(c) unless ent.consumptions.find(:first, :conditions => c)
    end
  end
