class MezuroPlugin::ProjectContent < Article
  include ActionView::Helpers::TagHelper

  settings_items :project_id

  validate_on_create :validate_kalibro_project_name
  validate_on_create :validate_repository_url

  def self.short_description
    'Mezuro project'
  end

  def self.description
    'Software project tracked by Kalibro'
  end

  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/show_project.rhtml'
    end
  end

  def project
    begin
      @project ||= Kalibro::Project.find(project_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @project
  end

  def repositories
    begin
      @repositories ||= Kalibro::Repository.repositories_of(project_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @repositories
  end

  def processing(repository_id)
    begin
      if Kalibro::Processing.has_ready_processing(repository_id)
        @processing ||= Kalibro::Processing.last_ready_processing_of(repository_id)
      end
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @processing
  end

  def processing_with_date(repository_id, date)
    begin
      if Kalibro::Processing.has_processing_before(repository_id, date)
        @processing ||= Kalibro::Processing.last_processing_before(repository_id, date)
      elsif Kalibro::Processing.has_processing_after(repository_id, date)
        @processing ||= Kalibro::Processing.last_processing_after(repository_id, date)
      end
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @processing
  end

  def module_result(repository_id, date = nil)
    @processing ||= date.nil? ? processing(repository_id) : processing_with_date(repository_id, date)
    begin
      @module_result ||= Kalibro::ModuleResult.find(@procesing.results_root_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @module_result
  end

  def result_history(module_id)
    begin
      @result_history ||= Kalibro::MetricResult.history_of(module_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
  end

  def description=(value)
    @description=value
  end

  def repositories=(value)
    @repositories = value.kind_of?(Array) ? value : [value]
    @repositories = @repositories.map { |element| to_object(element) }
  end

  def self.to_object value
    value.kind_of?(Hash) ? Kalibro::Repository.new(value) : value
  end

  after_save :send_project_to_service
  after_destroy :destroy_project_from_service

  private

  def validate_repository_url
    if(@repositories.nil? || repository_url == "")
      errors.add_to_base("Repository URL is mandatory")
    end
  end

  def send_project_to_service
    created_project = create_kalibro_project
    created_project.process_project(periodicity_in_days)
  end

  def create_kalibro_project
   Kalibro::Project.create(
      :name => name,
      :license => project_license,
      :description => description,
      :repository => {
        :type => repository_type,
        :address => repository_url
      },
      :configuration_name => configuration_name
    )
  end

  def destroy_project_from_service
    project.destroy unless project.nil?
  end

end
