namespace :ci do

  desc 'Continuous integration smoke test'
  task :smoke do

    current_branch = `git rev-parse --abbrev-ref HEAD`.strip
    from = ENV['PREV_HEAD'] || "origin/#{current_branch}"
    to = ENV['HEAD'] || current_branch
    changed_files = `git diff --name-only #{from}..#{to}`.split.select do |f|
      File.exist?(f)
    end

    changed_plugin_files = changed_files.select do |f|
      f.split(File::SEPARATOR).first == 'plugins'
    end
    changed_plugins = changed_plugin_files.map do |f|
      f.split(File::SEPARATOR)[1]
    end.uniq

    changed_files -= changed_plugin_files

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

    sh 'testrb', '-Itest', *tests unless tests.empty?
    sh 'cucumber', *features unless features.empty?
    sh 'cucumber', '-p', 'selenium', *features unless features.empty?

    changed_plugins.each do |plugin|
      task = "test:noosfero_plugins:#{plugin}"
      puts "Running #{task}"
      Rake::Task[task].execute
    end

  end

end
