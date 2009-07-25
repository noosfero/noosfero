class Object
  def __(*args)
    gettext(Noosfero.term(*args))
  end
  alias :getterm :__

  def n__(for_one, for_many, num)
    getterm(ngettext(for_one, for_many, num))
  end
end
