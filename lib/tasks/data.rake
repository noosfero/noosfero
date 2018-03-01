namespace :db do
  namespace :data do
    task :minimal do
      name = ENV['ENVIRONMENT_NAME'] || 'Noosfero'
      email = ENV['ADMIN_EMAIL'] ||'noosfero@localhost.localdomain'
      sh 'rails', 'runner', "Environment.create!(:name => '#{name}', :contact_email => '#{email}', :is_default => true) unless Environment.default"
      unless ENV['NOOSFERO_DOMAIN'].blank?
        sh 'rails', 'runner', "Environment.default.domains << Domain.new(:name => ENV['NOOSFERO_DOMAIN'])"
      end
      if !ENV['ADMIN_LOGIN'].blank? && !ENV['ADMIN_EMAIL'].blank? && !ENV['ADMIN_PASSWORD'].blank?
        sh 'rails', 'runner', "admin = User.create!(
                                 :login => ENV['ADMIN_LOGIN'],
                                 :email => ENV['ADMIN_EMAIL'],
                                 :password => ENV['ADMIN_PASSWORD'],
                                 :password_confirmation => ENV['ADMIN_PASSWORD'],
                                 :environment => Environment.default)
                               admin.activate
                               Environment.default.add_admin(admin.person)"
      end
    end
  end
end
