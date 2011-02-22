module FloatHelper

  def decimal_to_float( num )
    if num.count('.') == 1 && num.count(',') == 0
      # number like "12.34"
      return num.to_f
    end

    if num.count('.') == 0 && num.count(',') == 1
      # number like "12,34"
      return num.tr(',','.').to_f
    end

    if num.count('.') > 0 && num.count(',') > 0
      # number like "12.345.678,90" or "12,345,678.90"
      dec_sep = num.tr('0-9','')[-1].chr
      return num.tr('^0-9'+dec_sep,'').tr(dec_sep,'.').to_f
    end

    # if you are here is because there is only one
    # separator and this appears 2 times or more.
    # number like "12.345.678" or "12,345,678"

    return num.tr(',.','').to_f
  end

end
