module ShortFilename

  def short_filename(filename, limit_chars = 43)
    extname = File.extname(filename)
    basename = File.basename(filename,extname)
    return shrink(basename, extname, limit_chars) + extname
  end

  def short_filename_upper_ext(filename, limit_chars = 43)
    extname = File.extname(filename)
    display_name = shrink(File.basename(filename, extname), extname, limit_chars)
     return extname.present? ? (display_name + ' - ' + extname.upcase.delete(".")) : display_name
  end

  def shrink(filename, extname, limit_chars)
    return filename if filename.size <= limit_chars
    str_complement = '(...)'
    return filename[0..(limit_chars - extname.size - str_complement.size - 1)] + str_complement
  end

end
