class MezuroPluginReadingController < MezuroPluginMyprofileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
  
  def new
    reading_group_content = profile.articles.find(params[:id])
    @reading_group_name = reading_group_content.name
    @data_profile = reading_group_content.profile.identifier
    @reading_group_content_id = reading_group_content.id
  end
  
  def create
    reading_group_content = profile.articles.find(params[:id])

    reading = Kalibro::Reading.new( params[:reading] )
    reading.save(reading_group_content.reading_group_id)
    
    if( reading.errors.empty? )
      redirect_to "/#{profile.identifier}/#{reading_group_content.name.downcase.gsub(/\s/, '-').gsub(/[^0-9A-Za-z\-]/, '')}"
    else
      redirect_to_error_page reading.errors[0].message
    end
  end

  def edit
    reading_group_content = profile.articles.find(params[:id])
    @reading_group_name = reading_group_content.name
    @data_profile = reading_group_content.profile.identifier
    @reading_group_content_id = reading_group_content.id

    @reading_types = Kalibro::Reading.reading_types
    
    configurations = Kalibro::Configuration.all
    configurations = [] if (configurations.nil?)
    @configuration_select = configurations.map do |configuration|
      [configuration.name,configuration.id] 
    end

    @reading = reading_group_content.repositories.select{ |reading| reading.id.to_s == params[:reading_id] }.first
  end

  def update
    reading_group_content = profile.articles.find(params[:id])
    
    reading = Kalibro::Reading.new( params[:reading] )
    reading.save(reading_group_content.reading_group_id)

    if( reading.errors.empty? )
      reading.process
      redirect_to "/profile/#{profile.identifier}/plugin/mezuro/reading/show/#{reading_group_content.id}?reading_id=#{reading.id}"
    else
      redirect_to_error_page reading.errors[0].message
    end
  end

  def show 
    reading_group_content = profile.articles.find(params[:id])
    @reading_group_name = reading_group_content.name
    @reading = reading_group_content.repositories.select{ |reading| reading.id.to_s == params[:reading_id] }.first
    @configuration_name = Kalibro::Configuration.configuration_of(@reading.id).name
    @data_profile = reading_group_content.profile.identifier
    @data_content = reading_group_content.id
  end

  def destroy
    reading_group_content = profile.articles.find(params[:id])
    reading = reading_group_content.repositories.select{ |reading| reading.id.to_s == params[:reading_id] }.first
    reading.destroy
    if( reading.errors.empty? )
      redirect_to "/#{profile.identifier}/#{reading_group_content.name.downcase.gsub(/\s/, '-')}"
    else
      redirect_to_error_page reading.errors[0].message
    end
  end
  
end
