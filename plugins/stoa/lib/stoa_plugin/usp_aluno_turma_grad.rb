class StoaPlugin::UspAlunoTurmaGrad < ActiveRecord::Base

  establish_connection(:stoa)
  set_table_name('alunoturma_gr')

  def self.exists?(usp_id)
    StoaPlugin::UspUser.find_by_codpes(usp_id.to_i)
  end

  def self.classrooms_from_person(usp_id)
    StoaPlugin::UspAlunoTurmaGrad.find_all_by_codpes(usp_id)
  end

end
