task :default => [:test, :cucumber, :selenium]
task 'test:units' => 'noosfero:doc:translate'
task 'test:functionals' => 'noosfero:doc:translate'

task :selenium do
  sh 'xvfb-run cucumber -p selenium'
end
