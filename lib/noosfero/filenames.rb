module Noosfero::Filenames

  def short_filename(filename, limit_chars = 43)
    return filename if filename.size <= limit_chars
    extname = File.extname(filename)
    basename = File.basename(filename,extname)
    str_complement = '(...)'
    return basename[0..(limit_chars - extname.size - str_complement.size - 1)] + str_complement + extname
  end

end
