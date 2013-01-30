class MezuroPluginReadingController < MezuroPluginMyprofileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
  
  def new
    @reading_group_content = profile.articles.find(params[:id])
  end
  
  def create
    reading_group_content = profile.articles.find(params[:id])
    reading = Kalibro::Reading.new params[:reading]

    if( reading.save(reading_group_content.reading_group_id) )
      redirect_to reading_group_content.view_url
    else
      redirect_to_error_page reading.errors[0].message
    end
  end

  def edit
    @reading_group_content = profile.articles.find(params[:id])
    @reading = Kalibro::Reading.find params[:reading_id]
  end

  def update
    reading_group_content = profile.articles.find(params[:id])
    reading = Kalibro::Reading.new params[:reading]

    if( reading.save(reading_group_content.reading_group_id) )
      redirect_to reading_group_content.view_url
    else
      redirect_to_error_page reading.errors[0].message
    end
  end

  def destroy
    reading_group_content = profile.articles.find(params[:id])
    reading = Kalibro::Reading.find params[:reading_id]
    reading.destroy
    if( reading.errors.empty? )
      redirect_to reading_group_content.view_url
    else
      redirect_to_error_page reading.errors[0].message
    end
  end
  
end
