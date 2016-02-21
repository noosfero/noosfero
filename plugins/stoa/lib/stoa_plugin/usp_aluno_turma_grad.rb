class StoaPlugin::UspAlunoTurmaGrad < ApplicationRecord

  establish_connection(:stoa)

  self.table_name = :alunoturma_gr

  def self.exists?(usp_id)
    StoaPlugin::UspUser.find_by codpes: usp_id.to_i
  end

  def self.classrooms_from_person(usp_id)
    StoaPlugin::UspAlunoTurmaGrad.where codpes: usp_id
  end

end
