namespace :noosfero do
  namespace :translations do

    desc 'Update all translation files'
    task :update => ['updatepo', 'noosfero:doc:rebuild']

  end
end
