task :default => [:test, :cucumber, :selenium]
task 'test:units' => 'noosfero:doc:build'
task 'test:functionals' => 'noosfero:doc:build'

task :selenium do
  sh 'xvfb-run cucumber -p selenium'
end
