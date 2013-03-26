class MezuroPluginReadingController < MezuroPluginMyprofileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def new
    @reading_group_content = profile.articles.find(params[:id])
    
    readings = Kalibro::Reading.readings_of @reading_group_content.reading_group_id
    @parser="|*|"
    @labels_and_grades = readings.map {|reading| "#{reading.label}#{@parser}#{reading.grade}#{@parser}"}
  end

  def save
    reading_group_content = profile.articles.find(params[:id])
    reading = Kalibro::Reading.new params[:reading]

    if( reading.save )
      redirect_to reading_group_content.view_url
    else
      redirect_to_error_page reading.errors[0].message
    end
  end

  def edit
    @reading_group_content = profile.articles.find(params[:id])
    @reading = Kalibro::Reading.find params[:reading_id]
    
    readings = Kalibro::Reading.readings_of @reading_group_content.reading_group_id
    readings = readings.select {|reading| (reading.id != @reading.id)}
    @parser="|*|"
    @labels_and_grades = readings.map do |reading| 
      if(reading.id != @reading.id) 
        "#{reading.label}#{@parser}#{reading.grade}#{@parser}" 
      end
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
