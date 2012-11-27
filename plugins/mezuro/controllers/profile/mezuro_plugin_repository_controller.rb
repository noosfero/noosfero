  def processing(repository_id)
    begin
      if Kalibro::Processing.has_ready_processing(repository_id)
        @processing ||= Kalibro::Processing.last_ready_processing_of(repository_id)
      else
        @processing = Kalibro::Processing.last_processing_of(repository_id)
      end
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @processing
  end

  def processing_with_date(repository_id, date)
    begin
      if Kalibro::Processing.has_processing_after(repository_id, date)
        @processing ||= Kalibro::Processing.first_processing_after(repository_id, date)
      elsif Kalibro::Processing.has_processing_before(repository_id, date)
        @processing ||= Kalibro::Processing.last_processing_before(repository_id, date)
      end
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @processing
  end

  def module_result(repository_id, date = nil)
    @processing ||= date.nil? ? processing(repository_id) : processing_with_date(repository_id, date)
    begin
      @module_result ||= Kalibro::ModuleResult.find(@processing.results_root_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @module_result
  end

  def result_history(module_result_id)
    begin
      @result_history ||= Kalibro::MetricResult.history_of(module_result_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
  end
