namespace :db do
  namespace :data do
    task :minimal do
      sh './script/runner', "Environment.create!(:name => 'Noosfero', :is_default => true)"
      unless ENV['NOOSFERO_DOMAIN'].blank?
        sh './script/runner', "Environment.default.domains << Domain.new(:name => ENV['NOOSFERO_DOMAIN'])"
      end
    end
  end
end
