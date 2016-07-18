require "#{File.dirname(__FILE__)}/../test_helper"

class UploadedFileTest < ActionController::TestCase

  include ElasticsearchTestHelper

  def indexed_models
    [UploadedFile]
  end

  should 'index searchable fields for UploadedFile model' do
    UploadedFile::SEARCHABLE_FIELDS.each do |key, value|
      assert_includes indexed_fields(UploadedFile), key
    end
  end

  should 'index control fields for UploadedFile model' do
    UploadedFile::control_fields.each do |key, value|
      assert_includes indexed_fields(UploadedFile), key
      assert_equal indexed_fields(UploadedFile)[key][:type], value[:type].presence || 'string'
    end
  end

  should 'respond with should method to return public text_article' do
    assert TextArticle.respond_to? :should
  end

  should 'respond with nested_filter' do
    assert TextArticle.respond_to? :nested_filter
  end

  should 'have NestedProfile_filter in nested_filter' do
    assert TextArticle.nested_filter.include? NestedProfile.filter
  end

end
