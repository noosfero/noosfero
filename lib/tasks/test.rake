task :default => [:test, :cucumber, :selenium]

task :selenium do
  sh 'xvfb-run cucumber -p selenium'
end
