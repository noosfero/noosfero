#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'
require File.dirname(__FILE__) + '/fbes_populate_helper.rb'

GetText.locale = 'pt_BR'

categories = {}
cat0 = new_cat("Presta\303\247\303\243o de servi\303\247os (diversos)", nil)
categories[1] = cat0.id
cat1 = new_cat("ACOMPANHAMENTO", cat0)
categories[73] = cat1.id
cat2 = new_cat("A\303\207OUGUE", cat0)
categories[76] = cat2.id
cat3 = new_cat("ADMINISTRA\303\207\303\203O", cat0)
categories[92] = cat3.id
cat4 = new_cat("ADMINISTRA\303\207\303\203O ESCOLAR", cat3)
categories[94] = cat4.id
cat5 = new_cat("APOIO ADMINISTRATIVO", cat3)
categories[328] = cat5.id
cat6 = new_cat("ARQUIVO", cat3)
categories[399] = cat6.id
cat7 = new_cat("CAR\303\201TER ORGNIZATIVO", cat3)
categories[1533] = cat7.id
cat8 = new_cat("CERTIFICA\303\207\303\203O", cat3)
categories[1727] = cat8.id
cat9 = new_cat("CONTROLE OR\303\207AMENT\303\201RIO", cat3)
categories[2210] = cat9.id
cat10 = new_cat("COORDENA\303\207\303\203O ADMINISTRATIVA", cat3)
categories[2218] = cat10.id
cat11 = new_cat("Produ\303\247\303\243o agropecu\303\241ria, extrativismo e pesca", nil)
categories[2] = cat11.id
cat12 = new_cat("Produ\303\247\303\243o de artefatos artesanais", nil)
categories[3] = cat12.id
cat13 = new_cat("Produ\303\247\303\243o de fitoter\303\241picos, limpeza e higiene", nil)
categories[4] = cat13.id
cat14 = new_cat("Produ\303\247\303\243o de servi\303\247os de alimentso e bebidas", nil)
categories[5] = cat14.id
cat15 = new_cat("Produ\303\247\303\243o e servi\303\247os diversos", nil)
categories[6] = cat15.id
cat16 = new_cat("Produ\303\247\303\243o industrial(diversos)", nil)
categories[7] = cat16.id
cat17 = new_cat("Produ\303\247\303\243o mineral(diversa)", nil)
categories[8] = cat17.id
cat18 = new_cat("Produ\303\247\303\243o t\303\252xtil e confec\303\247\303\243o", nil)
categories[9] = cat18.id
cat19 = new_cat("Servi\303\247os de coleta e reciclagem de materiais", nil)
categories[10] = cat19.id
cities = {}
city0 = new_region("Alta Floresta d'Oeste", STATES[11], -11.93, -62.0)
cities[1100015] = city0
city1 = new_region("Ariquemes", STATES[11], -9.91, -63.04)
cities[1100023] = city1
city2 = new_region("Cabixi", STATES[11], -13.49, -60.55)
cities[1100031] = city2
city3 = new_region("Cacoal", STATES[11], -11.44, -61.45)
cities[1100049] = city3
city4 = new_region("Cerejeiras", STATES[11], -13.19, -60.81)
cities[1100056] = city4
city5 = new_region("Colorado do Oeste", STATES[11], -13.12, -60.54)
cities[1100064] = city5
city6 = new_region("Corumbiara", STATES[11], -12.96, -60.89)
cities[1100072] = city6
city7 = new_region("Costa Marques", STATES[11], -12.45, -64.23)
cities[1100080] = city7
city8 = new_region("Espig\303\243o d'Oeste", STATES[11], -11.53, -61.01)
cities[1100098] = city8
city9 = new_region("Guajar\303\241-Mirim", STATES[11], -10.78, -65.34)
cities[1100106] = city9
new_ent({ :name => "COOP. DOS ALUNOS DA  ESCOLA MEDIA DE AGROP. REG. CEPLAC.", 
                    :identifier => "coop.-dos-alunos-da-escola-media-de-agrop.-reg.-ceplac.", 
                    :contact_phone => "69-35352063", 
                    :address => "ROD O1 KM 13 CEP: 78931-540", 
                    :lat => -9.90437, 
                    :lng => -63.0456, 
                    :geocode_precision => 8, 
                    :data => { :id_sies => 1949 }, 
                    :contact_email => nil,
                    :categories => [cities[1100023]]},
                    [{ :name => "PEIXE" , :product_category_id => categories[4940] }, { :name => "OVOS" , :product_category_id => categories[4603] }, { :name => "SU\303\215NOS (CABE\303\207A)" , :product_category_id => categories[6198] }], 
                    [{ :product_category_id => categories[4126]}])
new_ent({ :name => "COOPERAT DE CREDITO RURAL DE ARIQUEMES", 
                    :identifier => "cooperat-de-credito-rural-de-ariquemes", 
                    :contact_phone => "69-35360640", 
                    :address => "Av: Tancredo Neves  N\302\272: 2077 CEP: 78931-740", 
                    :lat => -9.90355, 
                    :lng => -63.0352, 
                    :geocode_precision => 8, 
                    :data => { :id_sies => 21246 }, 
                    :contact_email => "crediari@ariquemes.com.br",
                    :categories => [cities[1100023]]},
                    [{ :name => "OPERA\303\207\303\225ES DE CR\303\211DITO" , :product_category_id => categories[4560] }], 
                    [])
new_ent({ :name => "ASSOCIA\303\207\303\203O DOS MOTOTAXISTAS DE ARIQUEMES", 
                    :identifier => "associacao-dos-mototaxistas-de-ariquemes", 
                    :contact_phone => "69-35360756", 
                    :address => "Av: Jamari  N\302\272:3044 CEP: 78931-000", 
                    :lat => -9.9248, 
                    :lng => -63.0235, 
                    :geocode_precision => 8, 
                    :data => { :id_sies => 85911 }, 
                    :contact_email => nil,
                    :categories => [cities[1100023]]},
                    [{ :name => "TRANSPORTE DE PASSAGEIROS" , :product_category_id => categories[6709] }], 
                    [{ :product_category_id => categories[2030]}, { :product_category_id => categories[3980]}, { :product_category_id => categories[4881]}])
new_ent({ :name => "ASSOCIA\303\207\303\203O DOS PROD. E DIST. DE LEITE DE ARIQUEMES", 
                    :identifier => "associacao-dos-prod.-e-dist.-de-leite-de-ariquemes", 
                    :contact_phone => "69-92170143", 
                    :address => "Av: Tancredo neves  esquina c/ linha C65 CEP: 78930-000", 
                    :lat => -9.91, 
                    :lng => -63.04, 
                    :geocode_precision => -1, 
                    :data => { :id_sies => 85913 }, 
                    :contact_email => nil,
                    :categories => [cities[1100023]]},
                    [{ :name => "LEITE" , :product_category_id => categories[3762] }], 
                    [{ :product_category_id => categories[4126]}])
new_ent({ :name => "ASSOC. DOS PROD. HORTFRUTGRANGERO DO CINTUR\303\203O VERDE", 
                    :identifier => "assoc.-dos-prod.-hortfrutgrangero-do-cinturao-verde", 
                    :contact_phone => "69-92850407", 
                    :address => "Rua: Falc\303\243o, Via dos colibr\303\255s , Lota 49, Gleba 05 CEP: 78930-000", 
                    :lat => -9.91, 
                    :lng => -63.04, 
                    :geocode_precision => -1, 
                    :data => { :id_sies => 86939 }, 
                    :contact_email => nil,
                    :categories => [cities[1100023]]},
                    [{ :name => "HORTIGRANJEIROS" , :product_category_id => categories[3492] }], 
                    [{ :product_category_id => categories[4126]}])
new_ent({ :name => "ASSOCIA\303\207\303\203O CACAOLENSE DE APICULTORES", 
                    :identifier => "associacao-cacaolense-de-apicultores", 
                    :contact_phone => "69-34412405", 
                    :address => "Av. Castelo Branco, N\302\272:2372 CEP: 78975-010", 
                    :lat => -11.4443, 
                    :lng => -61.4448, 
                    :geocode_precision => 8, 
                    :data => { :id_sies => 24142 }, 
                    :contact_email => nil,
                    :categories => [cities[1100049]]},
                    [{ :name => "CERA (APICULTURA)" , :product_category_id => categories[1710] }, { :name => "MEL" , :product_category_id => categories[4268] }, { :name => "PR\303\223POLIS" , :product_category_id => categories[5435] }], 
                    [{ :product_category_id => categories[2646]}, { :product_category_id => categories[2694]}, { :product_category_id => categories[3343]}])
new_ent({ :name => "ASSOC. RURAL CACAOLENSE ORGANIZADA PARA AJUDA MUTUA", 
                    :identifier => "assoc.-rural-cacaolense-organizada-para-ajuda-mutua", 
                    :contact_phone => "69-34412005, 69-92859207", 
                    :address => "Rua: Princesa Izabel N\302\272: 1640 CEP: 78975-000", 
                    :lat => -11.44, 
                    :lng => -61.45, 
                    :geocode_precision => -1, 
                    :data => { :id_sies => 79229 }, 
                    :contact_email => nil,
                    :categories => [cities[1100049]]},
                    [{ :name => "CAF\303\211" , :product_category_id => categories[1262] }], 
                    [{ :product_category_id => categories[2694]}, { :product_category_id => categories[4126]}, { :product_category_id => categories[4881]}])
new_ent({ :name => "ASSOCIA\303\207\303\203O DE ARTES\303\225ES DE CACOAL", 
                    :identifier => "associacao-de-artesoes-de-cacoal", 
                    :contact_phone => "69-34414030", 
                    :address => "Rua: Padre Jos\303\251 de Anchieta  N\302\272:640 CEP: 78975-395", 
                    :lat => -11.44, 
                    :lng => -61.45, 
                    :geocode_precision => -1, 
                    :data => { :id_sies => 79231 }, 
                    :contact_email => "spitwak@bol.com.br",
                    :categories => [cities[1100049]]},
                    [{ :name => "ARTEFATOS DE CER\303\202MICA" , :product_category_id => categories[437] }, { :name => "ARTIGOS DE CAMA, MESA E BANHO" , :product_category_id => categories[502] }, { :name => "M\303\223VEIS" , :product_category_id => categories[4409] }], 
                    [{ :product_category_id => categories[665]}, { :product_category_id => categories[4024]}])
new_ent({ :name => "F\303\223RUM DAS ORGANIZA\303\207\303\225ES DO POVO PAITER SURU\303\215 DE ROND\303\224NIA", 
                    :identifier => "forum-das-organizacoes-do-povo-paiter-surui-de-rondonia", 
                    :contact_phone => "69-34431262, 69-81179518", 
                    :address => "Rua : Geraldo Cardoso Campos  N\302\272: 4343 CEP: 78975-000", 
                    :lat => -11.44, 
                    :lng => -61.45, 
                    :geocode_precision => -1, 
                    :data => { :id_sies => 79232 }, 
                    :contact_email => "forumpaiter@yahoo.com.br",
                    :categories => [cities[1100049]]},
                    [{ :name => "ARROZ" , :product_category_id => categories[429] }, { :name => "CAF\303\211" , :product_category_id => categories[1262] }, { :name => "FEIJ\303\203O" , :product_category_id => categories[2970] }], 
                    [{ :product_category_id => categories[2646]}, { :product_category_id => categories[3973]}, { :product_category_id => categories[4975]}])
new_ent({ :name => "COOP. DE TRAB. EM COURO E PELES E PROD.DE CAL\303\207ADOS BELLING", 
                    :identifier => "coop.-de-trab.-em-couro-e-peles-e-prod.de-calcados-belling", 
                    :contact_phone => "69-92160872", 
                    :address => "Av:JK N\302\272: 784 CEP: 78978-000", 
                    :lat => -11.44, 
                    :lng => -61.45, 
                    :geocode_precision => -1, 
                    :data => { :id_sies => 79233 }, 
                    :contact_email => nil,
                    :categories => [cities[1100049]]},
                    [{ :name => "CAL\303\207ADOS" , :product_category_id => categories[1367] }], 
                    [{ :product_category_id => categories[2302]}, { :product_category_id => categories[3027]}, { :product_category_id => categories[6150]}])
