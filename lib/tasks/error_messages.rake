namespace :error do
  task :messages => :makemo do
    require 'erb'
    Dir.glob(RAILS_ROOT + '/public/*.html.erb').each do |template|
      puts "Processing #{template}"
      target = template.gsub(/.erb$/, '')
      erb = ERB.new(File.read(template))
      File.open(target, 'w') do |file|
        file.write(erb.result)
      end
    end
  end
end
