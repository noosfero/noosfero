class Kalibro::Client::BaseToolClient
  
  def initialize
    @port = Kalibro::Client::Port.new('BaseTool')
  end

  def base_tool_names
    @port.request(:get_base_tool_names)[:base_tool_name].to_a
  end

  def base_tool(name)
    hash = @port.request(:get_base_tool, {:base_tool_name => name})[:base_tool]
    Kalibro::Entities::BaseTool.from_hash(hash)
  end

end
