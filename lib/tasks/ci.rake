namespace :ci do

  desc 'Continuous integration smoke test'
  task :smoke do
    if ENV['HEAD'] && ENV['PREV_HEAD']
      from = ENV['PREV_HEAD']
      to = ENV['HEAD']
      changed_files = `git diff --name-only #{from}..#{to}`.split

      # explicitly changed tests
      tests = changed_files.select { |f| f =~ /test\/.*_test\.rb$/ }
      features = changed_files.select { |f| f =~ /\.feature$/ }

      # match changed code files to their respective tests
      changed_files.each do |f|
        if f =~ /^(app|lib)\//
          basename = File.basename(f, '.rb')
          Dir.glob("test/**/#{basename}_test.rb").each do |t|
            tests << t unless tests.include?(t)
          end
        end
      end

      sh 'testrb', *tests unless tests.empty?
      sh 'cucumber', *features unless features.empty?
      sh 'cucumber', '-p', 'selenium', *features unless features.empty?
    end
  end

end
