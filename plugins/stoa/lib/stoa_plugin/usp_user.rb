class StoaPlugin::UspUser < ActiveRecord::Base

  establish_connection(:stoa)
  set_table_name('pessoa')

  SALT=YAML::load(File.open(StoaPlugin.root_path + '/config.yml'))['salt']

  alias_attribute :cpf, :numcpf
  alias_attribute :rg, :numdocidf

  def self.exists?(usp_id)
    !StoaPlugin::UspUser.find(:first, :conditions => {:codpes => usp_id}).nil?
  end

  def self.matches?(usp_id, field, value)
    user = StoaPlugin::UspUser.find(:first, :conditions => {:codpes => usp_id})
    return false if user.nil? || !user.respond_to?(field) || value.blank?
    user.send(field) == Digest::MD5.hexdigest(SALT+value.to_s)
  end

end
