class Theme

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def name
    id
  end

  class << self
    def system_themes
      Dir.glob(RAILS_ROOT + '/public/designs/themes/*').map do |item|
        File.basename(item)
      end.map do |item|
        new(item)
      end
    end
  end
end
