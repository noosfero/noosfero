namespace :noosfero do
  namespace :translations do

    desc 'Update all translation files'
    task :update => ['gettext:po:update', 'noosfero:doc:rebuild']

    desc 'Compiles all translations'
    task :compile => ['gettext:mo:update', 'noosfero:doc:translate']

  end
end
