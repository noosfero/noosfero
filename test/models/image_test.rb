require_relative "../test_helper"

class ImageTest < ActiveSupport::TestCase
  fixtures :images

  def setup
    @profile = create_user("testinguser").person
  end
  attr_reader :profile

  should "have thumbnails options" do
    [:big, :thumb, :portrait, :minor, :icon].each do |option|
      assert Image.attachment_options[:thumbnails].include?(option), "should have #{option}"
    end
  end

  should "match max_size in validates message of size field" do
    image = build(Image, filename: "fake_filename.png")
    image.valid?

    assert_match /#{Image.max_size.to_humanreadable}/, image.errors[:size].first
  end

  should "create thumbnails after processing jobs" do
    file = create(Image, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))
    profile.update_attribute(:image_id, file.id)

    Image.attachment_options[:thumbnails].each do |suffix, size|
      assert File.exists?(Image.find(file.id).public_filename(suffix))
    end
    file.destroy
  end

  should "set thumbnails_processed to true after creating thumbnails" do
    file = create(Image, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))
    profile.update_attribute(:image_id, file.id)

    assert Image.find(file.id).thumbnails_processed
    file.destroy
  end

  should "have thumbnails_processed attribute" do
    assert Image.new.respond_to?(:thumbnails_processed)
  end

  should "return false by default in thumbnails_processed" do
    refute Image.new.thumbnails_processed
  end

  should "set thumbnails_processed to true" do
    file = Image.new
    file.thumbnails_processed = true

    assert file.thumbnails_processed
  end

  should "use origin image if thumbnails were not processed and fallback is enabled" do
    file = create(Image, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))
    profile.update_attribute(:image_id, file.id)

    Image.any_instance.stubs(:thumbnails_processed).returns(false)
    assert_match(/rails.png/, Image.find(file.id).public_filename(:thumb))

    file.destroy
  end

  should "return image thumbnail if thumbnails were processed" do
    file = create(Image, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))
    profile.update_attribute(:image_id, file.id)

    assert_match(/rails_thumb.png/, Image.find(file.id).public_filename(:thumb))

    file.destroy
  end

  should "store width and height after processing" do
    file = create(Image, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))
    profile.update_attribute(:image_id, file.id)
    file.create_thumbnails

    file = Image.find(file.id)
    assert_equal [50, 64], [file.width, file.height]
  end

  should "have a loading image to each size of thumbnails" do
    Image.attachment_options[:thumbnails].each do |suffix, size|
      image = Rails.root.join("public/images/icons-app/image-loading-#{suffix}.png")
      assert File.exists?(image), "#{image} should exist."
    end
  end

  should "upload to a folder with same name as the schema if database is postgresql" do
    uses_postgresql
    file = create(Image, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))
    profile.update_attribute(:image_id, file.id)
    assert_match(/images\/test_schema\/\d{4}\/\d{4}\/rails.png/, Image.find(file.id).public_filename)
    file.destroy
    uses_sqlite
  end

  should "upload to path prefix folder if database is not postgresql" do
    uses_sqlite
    file = create(Image, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"))
    profile.update_attribute(:image_id, file.id)
    assert_match(/images\/\d{4}\/\d{4}\/rails.png/, Image.find(file.id).public_filename)
    file.destroy
  end

  should "not allow script files to be uploaded without append .txt in the end" do
    file = create(Image, uploaded_data: fixture_file_upload("files/hello_world.php", "image/png"))
    assert_equal "hello-world.php.txt", file.filename
  end

  should "have an owner" do
    owner = fast_create(Block)
    file = create(Image, uploaded_data: fixture_file_upload("/files/rails.png", "image/png"), owner: owner)
    assert_equal owner, file.owner
  end
end
