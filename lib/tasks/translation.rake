namespace :noosfero do
  namespace :translations do

    desc 'Update all translation files'
    task :update => ['gettext:po:update', 'noosfero:doc:rebuild']

    desc 'Compiles all translations'
    task :compile do
      sh 'find locale plugins/*/locale -name "*.po" -exec touch "{}" ";" || true'
      Rake::Task['gettext:mo:update'].invoke
      Rake::Task['noosfero:doc:translate'].invoke
    end
  end
end
