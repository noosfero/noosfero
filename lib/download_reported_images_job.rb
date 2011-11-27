class DownloadReportedImagesJob < Struct.new(:abuse_report, :article)
  def perform
    images_paths = article.image? ? [File.join(article.profile.environment.top_url, article.public_filename(:display))] : article.body_images_paths
    images_paths.each do |image_path|
      image = get_image(image_path)
      reported_image = ReportedImage.create!( :abuse_report => abuse_report,
                                              :uploaded_data => image,
                                              :filename => File.basename(image_path),
                                              :size => image.size )
      abuse_report.content = parse_content(abuse_report, image_path, reported_image)
    end
    abuse_report.save!
  end

  def get_image(image_path)
    image = ActionController::UploadedTempfile.new('reported_image')
    image.write(Net::HTTP.get(URI.parse(image_path)))
    image.original_path = 'tmp/' + File.basename(image_path)
    image.content_type = 'image/' + File.extname(image_path).gsub('.','')
    image
  end

  def parse_content(report, old_path, image)
    old_path = old_path.gsub(report.reporter.environment.top_url, '')
    report.content.gsub(/#{old_path}/, image.public_filename)
  end
end
