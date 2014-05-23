class DocSection < DocItem

  def self.root_dir
    @root_dir ||= Rails.root.join('doc', 'noosfero')
  end

  def items
    @items ||= load_items
  end

  def find(id)
    topic = items.find {|item| item.id == id }
    if topic
      topic
    else
      raise DocItem::NotFound
    end
  end

  def self.all(language = 'en', force = false)
    if force
      @all = nil
    end
    @all ||= {}
    @all[language] ||= load_dirs(language)
  end

  def self.find(id, language = 'en', force = false)
    if id.blank?
      root(language)
    else
      section = all(language, force).find {|item| item.id == id }
      if section
        section
      else
        raise DocItem::NotFound
      end
    end
  end

  def self.root(language = 'en')
    @root ||= {}
    @root[language] ||= load(root_dir, language)
  end

  private

  attr_accessor :directory

  def self.load_dirs(language)
    Dir.glob(File.join(root_dir, '*')).select {|item| File.directory?(item) }.map do |dir|
      load(dir, language)
    end
  end

  def self.load(dir, language)
    index = DocTopic.loadfile(self._find_topic(dir, 'index', language))
    toc = DocTopic.loadfile(self._find_topic(dir, 'toc', language))
    new(:id => File.basename(dir), :title => index.title, :text => index.text + toc.text, :language => language, :directory => dir)
  end

  def self._find_topic(dir, id, language)
    language_suffix = _language_suffix(language)
    [
      File.join(dir, "#{id}#{language_suffix}.xhtml"),
      File.join(dir, "#{id}.en.xhtml")
    ].find {|file| File.exist?(file) } || raise(DocItem::NotFound)
  end

  def load_items
    if directory
      language_suffix = self.class._language_suffix(language)
      Dir.glob(File.join(directory, "*.en.xhtml")).map do |file|
        # extract the available id's from the English versions
        File.basename(file).sub(/\.en.xhtml$/, '')
      end.map do |id|
        # load a translation, if available, or the original English topic
        DocTopic.loadfile(self.class._find_topic(directory, id, language))
      end
    else
      []
    end
  end

  def self._language_suffix(language)
    (!language || language == 'en') ? '' : ('.' + language)
  end


end
