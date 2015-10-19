module SanitizeParams

  protected

    # Check each request parameter for 
    # improper HTML or Script tags
    def sanitize_params
      sanitize_params_hash(request.params)    
    end

    # Given a params list sanitize all
    def sanitize_params_hash(params)
      params.each { |k, v|
        if v.is_a?(String)        
          params[k] = sanitize_param v
        elsif v.is_a?(Array)
          params[k] = sanitize_array v
        elsif v.kind_of?(Hash)
          params[k] = sanitize_params_hash(v)
        end
      }    
    end

    # If the parameter was an array, 
    # try to sanitize each element in the array
    def sanitize_array(array)
      array.map! { |e| 
        if e.is_a?(String)
          sanitize_param e
        end
      }
      return array
    end

    # Santitize a single value
    def sanitize_param(value)
      allowed_tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
      ActionController::Base.helpers.sanitize(value, tags: allowed_tags, attributes: %w(href title))
    end

end    
