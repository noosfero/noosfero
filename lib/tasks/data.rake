namespace :db do
  namespace :data do
    task :minimal do
      sh 'rails', 'runner', "Environment.create!(:name => 'Noosfero', :contact_email => 'noosfero@localhost.localdomain', :is_default => true)"
      unless ENV['NOOSFERO_DOMAIN'].blank?
        sh 'rails', 'runner', "Environment.default.domains << Domain.new(:name => ENV['NOOSFERO_DOMAIN'])"
      end
    end
  end
end
