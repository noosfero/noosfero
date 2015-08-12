require_relative "../test_helper"

class I18nTest < ActiveSupport::TestCase

  # XXX this duplicates the list from lib/tasks/gettext.rake
  files_to_translate = [
    "{app,lib}/**/*.{rb,rhtml,erb}",
    'config/initializers/*.rb',
    'public/*.html.erb',
    'public/designs/themes/{base,noosfero,profile-base}/*.{rhtml,html.erb}',
  ].map { |pattern| Dir.glob(pattern) }.flatten

  plugins_files_to_translate = Dir.glob("plugins/**/*.{rb,html.erb}")

  (files_to_translate + plugins_files_to_translate).each do |f|
    test "translation marks in #{f}" do
      lines = File.readlines(f).select do |line|
        line =~ /\b_\(["'][^)]*#\{/
      end
      assert lines == [], "found interpolation in translatable strings:\n" + lines.join("\n")
    end
  end

end

