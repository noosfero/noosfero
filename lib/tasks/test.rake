task :default => [:test, :cucumber, :selenium]
task 'test:units' => 'noosfero:doc:build'
task 'test:functionals' => 'noosfero:doc:build'

task :selenium do
  if ENV['DISPLAY'].blank?
    puts "I: Not running selenium tests, graphical environment is not available"
  else
    sh 'cucumber -p selenium'
  end
end
