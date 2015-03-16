root = Pathname(File.dirname(__FILE__)).join('../../').expand_path
templates = Dir.glob(root.join('public', '*.html.erb'))
targets = []
templates.each do |template|
  target = template.gsub(/.erb$/, '')
  targets << target
  file target => [:makemo, template] do
    require 'erb'
    erb = ERB.new(File.read(template))
    File.open(target, 'w') do |file|
      file.write(erb.result)
    end
    puts "#{template} -> #{target}"
  end
end

namespace :noosfero do
  namespace 'error-pages' do
    desc 'Translates Noosfero error pages'
    task :translate => targets
  end
end
