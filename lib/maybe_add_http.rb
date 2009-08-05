module MaybeAddHttp

  def maybe_add_http(value)
    return '' if value.blank?
    if value =~ /https?:\/\//
      value
    else
      'http://' + value
    end
  end

end
