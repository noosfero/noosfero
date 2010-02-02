task :default => [:test, :cucumber]

task 'test:units' => 'noosfero:doc:build'
task 'test:functionals' => 'noosfero:doc:build'
