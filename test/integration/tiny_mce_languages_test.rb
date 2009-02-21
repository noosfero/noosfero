require "#{File.dirname(__FILE__)}/../test_helper"

class TinyMceLanguagesTest < ActionController::IntegrationTest

  Noosfero.available_locales.map { |locale| locale.split('_').first }.each do |language|
    should "have TinyMCE #{language} language pack" do
      assert_exists_tinymce_language_file("langs/#{language}.js")
      assert_exists_tinymce_language_file("themes/simple/langs/#{language}.js")
      assert_exists_tinymce_language_file("themes/advanced/langs/#{language}.js")
    end
  end

  def assert_exists_tinymce_language_file(file)
    filename = RAILS_ROOT + "/public/javascripts/tinymce/jscripts/tiny_mce/" + file
    assert(File.exists?(filename), filename + " must exist")
  end


end
