module Noosfero::TranslatableContent

  def translatable?
    parent.nil? || !parent.forum?
  end
end
