require File.dirname(__FILE__) + '/fbes_populate_helper.rb'

cat_produtos = ProductCategory.find_by_path('produtos')
cat_produtos_diversos = cat_produtos.children.create!(:name => 'Produtos diversos', :environment => cat_produtos.environment)
cat_servicos = ProductCategory.find_by_path('servicos')
cat_servicos_diversos = cat_servicos.children.find_by_name('Prestação de serviços diversos')
cat_diversos = ProductCategory.find_by_path('producao-e-servicos-diversos')

cat_to_produtos = ProductCategory.top_level_for(Environment.default).select{|pc|![cat_diversos, cat_servicos, cat_produtos].include?(pc)}
cat_to_servicos = cat_diversos.children.select{|pc| ["Ação comunitária","Carro alugado","Carro de som","Distribuiçao de água","Em fase de implantação","Ilegível","Mensalidades","Pistas skate"].include?(pc.name)}
cat_to_produtos += (cat_diversos.children - cat_to_servicos)

cat_to_produtos.each do |cat|
  cat.parent = cat_produtos_diversos
  cat.save!
end

cat_to_produtos.each do |cat|
  cat.parent = cat_servicos_diversos
  cat.save!
end

cat_diversos.destroy
