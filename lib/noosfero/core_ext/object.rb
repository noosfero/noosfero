class Object
  def __(*args)
    gettext(Noosfero.term(*args))
  end
  alias :getterm :__
end
