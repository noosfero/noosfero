namespace :db do
  namespace :data do
    task :minimal do
      environment = Environment.create!(:name => 'Noosfero', :is_default => true)
      unless ENV['NOOSFERO_DOMAIN'].blank?
        environment.domains << Domain.new(:name => ENV['NOOSFERO_DOMAIN'])
      end
    end
  end
end
