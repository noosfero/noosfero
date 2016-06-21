require "#{File.dirname(__FILE__)}/../../test_helper"

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
      assert_includes indexed_fields(UploadedFile)[key][:type], value[:type].presence || 'string'
    end
  end

end
