class StoaPlugin::UspUser < ActiveRecord::Base

  establish_connection(:stoa)
  set_table_name('pessoa')

  SALT=YAML::load(File.open(StoaPlugin.root_path + '/config.yml'))['salt']

  alias_attribute :cpf, :numcpf
  alias_attribute :birth_date, :dtanas

  def self.exists?(usp_id)
    !StoaPlugin::UspUser.find(:first, :conditions => {:codpes => usp_id}).nil?
  end

  def self.matches?(usp_id, field, value)
    user = StoaPlugin::UspUser.find(:first, :conditions => {:codpes => usp_id})
    return false if user.nil? || !user.respond_to?(field) || value.blank?
    case field.to_sym
    when :cpf
      user.cpf == Digest::MD5.hexdigest(SALT+value.to_s)
    when :birth_date
      user.birth_date.to_s == value
    end
  end

end
