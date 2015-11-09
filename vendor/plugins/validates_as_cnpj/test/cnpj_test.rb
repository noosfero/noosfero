
require File.dirname(__FILE__) + '/abstract_unit'
require '../lib/validates_as_cnpj'

# Modelo
class CNPJData < ActiveRecord::Base
  self.table_name = "cnpjs"

  validates_as_cnpj :cnpj
end

# Testes
class CNPJsTest < Test::Unit::TestCase
  def test_aceita_cnpj_nulo_por_que_deve_ser_barrado_por_validates_presence_of
    cnpj_valido = CNPJData.new(:id => 1, :cnpj => nil)

    assert cnpj_valido.save, "Nao salvou CNPJ nulo."
  end

  def test_aceita_cnpj_vazio_por_que_deve_ser_barrado_por_validates_presence_of
    cnpj_valido = CNPJData.new(:id => 1, :cnpj => "")

    assert cnpj_valido.save, "Nao salvou CNPJ vazio."
  end

  def test_cnpj_incompleto
    cnpj_invalido = CNPJData.new(:id => 1, :cnpj => "123")

    assert ( not cnpj_invalido.save ), "Salvou CNPJ incompleto."
  end

  def test_cnpj_invalido_sem_pontuacao
    cnpj_invalido = CNPJData.new(:id => 1, :cnpj => "00000000000000")

    assert ( not cnpj_invalido.save ), "Salvou CNPJ invalido."
  end

  def test_cnpj_valido_sem_pontuacao
    cnpj_valido = CNPJData.new(:id => 1, :cnpj => "04613251000100")

    assert cnpj_valido.save, "Nao salvou CNPJ valido."
  end

  def test_cnpj_invalido_sem_pontuacao_com_digitos_verificadores_invertidos
    cnpj_invalido = CNPJData.new(:id => 1, :cnpj => "10002574000125")

    assert ( not cnpj_invalido.save ), "Salvou CNPJ invalido."
  end

  def test_cnpj_invalido_com_pontuacao
    cnpj_invalido = CNPJData.new(:id => 1, :cnpj => "51.357.999/1110-98")

    assert ( not cnpj_invalido.save ), "CNPJ invalido foi salvo."
  end

  def test_cnpj_valido_com_pontuacao
    cnpj_valido = CNPJData.new(:id => 1, :cnpj => "94.132.024/0001-48")

    assert ( cnpj_valido.save ), "CNPJ valido nao foi salvo."
  end
end
