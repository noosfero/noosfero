class Kalibro::Entities::ModuleNode < Kalibro::Entities::Entity

  attr_accessor :module, :child

  def module=(value)
    @module = to_entity(value, Kalibro::Entities::Module)
  end

  def child=(value)
    @child = to_entity_array(value, Kalibro::Entities::ModuleNode)
  end

  def children
    @child
  end

  def children=(children)
    @child = children
  end

  def print
    cell = "<td>#{@module.name} (#{@module.granularity})</td>"
    return "<table><tr><td width=\"1\"></td>" + cell + "</tr></table>" if @child.nil?

    id = @module.name
    "<table>" +
      "<tr>" +
        "<td width=\"10%\">" +
          "<img id=\"#{id}_plus\" onclick=\"toogle('#{id}')\"" +
            "alt=\"+\" src=\"/plugins/mezuro/images/plus.png\" class=\"link\"" +
            "style=\"display: none\"/>" +
          "<img id=\"#{id}_minus\" onclick=\"toogle('#{id}')\"" +
            "alt=\"-\" src=\"/plugins/mezuro/images/minus.png\" class=\"link\"" +
            "/>" +
        "</td>" +
        cell +
      "</tr>" +
      "<tr id=\"#{id}_hidden\">" +
        "<td></td>" +
        "<td style=\"text-align: left\">" +
          @child.collect { |child| child.print }.to_s +
        "</td>" +
      "</tr>" +
    "</table>"
  end

end