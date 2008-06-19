class Integer
  def to_humanreadable
    value = self
	  if value < 1023
	  	return "%i bytes" % value
    end
	  value /= 1024

	  if value < 1023
	  	return "%1.1f KB" % value
    end
	  value /= 1024

	  if value < 1023
	  	return "%1.1f MB" % value
    end
	  value /= 1024

	  if value < 1023
	  	return "%1.1f GB" % value
    end
	  value /= 1024

	  if value < 1023
	  	return "%1.1f TB" % value
    end
	  value /= 1024

	  if value < 1023
	  	return "%1.1f PB" % value
    end
	  value /= 1024

	  if value < 1023
	  	return "%1.1f EB" % value
    end
	  value /= 1024
  end
end
