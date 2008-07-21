class Object
  def __(*args)
    gettext(Noosfero.term(*args))
  end
  alias :getterm :__

  def n__(for_one, for_many, num)
    ngettext(getterm(for_one), getterm(for_manu), num)
  end
end
