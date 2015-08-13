require 'test_helper'

class StoaPlugin::UspUserTest < ActiveSupport::TestCase

  SALT=YAML::load(File.open(StoaPlugin.root_path + 'config.yml'))['salt']

  @db = Tempfile.new('stoa-test')
  configs = ActiveRecord::Base.configurations['stoa'] = {:adapter => 'sqlite3', :database => @db.path}
  ActiveRecord::Base.establish_connection(:stoa)
  ActiveRecord::Schema.verbose = false
  ActiveRecord::Schema.create_table "pessoa" do |t|
    t.integer  "codpes"
    t.text     "numcpf"
    t.date     "dtanas"
  end
  ActiveRecord::Base.establish_connection(:test)

  def setup
    StoaPlugin::UspUser.create({:codpes => 123456, :cpf => Digest::MD5.hexdigest(SALT+'12345678'), :birth_date => '1970-01-30'}, :without_protection => true)
  end

  should 'check existence of usp_id' do
    assert  StoaPlugin::UspUser.exists?(123456)
    refute StoaPlugin::UspUser.exists?(654321)
  end

  should 'check if usp_id matches with a cpf' do
    assert  StoaPlugin::UspUser.matches?(123456, :cpf, 12345678)
    refute StoaPlugin::UspUser.matches?(123456, :cpf, 87654321)
    refute StoaPlugin::UspUser.matches?(654321, :cpf, 12345678)
  end

  should 'check if usp_id matches with a birth_date' do
    assert  StoaPlugin::UspUser.matches?(123456, :birth_date, '1970-01-30')
    refute StoaPlugin::UspUser.matches?(123456, :birth_date, '1999-01-30')
    refute StoaPlugin::UspUser.matches?(654321, :birth_date, '1970-01-30')
  end

  should 'filter leading zeroes of id codes on exists and matches' do
    assert  StoaPlugin::UspUser.exists?('0000123456')
    assert  StoaPlugin::UspUser.matches?(123456, :cpf, '00012345678')
  end

  should 'return false if field is nil' do
    assert  !StoaPlugin::UspUser.matches?(123456, nil, '00012345678')
  end
end
