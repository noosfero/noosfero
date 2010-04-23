class DocTopic < DocItem
  def self.loadfile(file)
    if !File.exist?(file)
      raise DocItem::NotFound
    end
    lines = File.readlines(file) 
    title_line = _find_title(lines)
    File.basename(file) =~ /(.*)\.([^\.]+)\.xhtml$/
    id = $1
    language = $2
    new(:id => id, :title => title(title_line), :text => lines.join, :language => language, :order => order(title_line))
  end

  def self._find_title(lines)
    lines.find {|line| line =~ /^(<h1.*>.*<\/h1>)/ }
    $1
  end

  def self.title(line)
    line =~ /<h1.*>(.*)<\/h1>/
    $1
  end

  def self.order(line)
    line =~ /<h1 class="order-(.*)">.*<\/h1>/
    $1
  end

end
