class DocTopic < DocItem
  def self.loadfile(file)
    lines = File.readlines(file) 
    title = _find_title(lines)
    File.basename(file) =~ /(.*)\.([^\.]+)\.xhtml$/
    id = $1
    language = $2
    new(:id => id, :title => title, :text => lines.join, :language => language)
  end

  def self._find_title(lines)
    lines.find {|line| line =~ /^<h1>(.*)<\/h1>/ }
    $1
  end
end
